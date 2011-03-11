require 'uri'
require 'mongo'
require 'lib/dpll'

module Sat
  class << self
    def connect
      if ENV['MONGOHQ_URL']
        uri = URI.parse(ENV['MONGOHQ_URL'])
        conn = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
        @db = conn.db(uri.path.gsub(/^\//, ''))
      else
        @db = Mongo::Connection.new.db("mongo-sinatra-app")
      end
      @collection = @db.collection("cnfs")
    end
    
    def find(search, conditions = nil)
      conditions["_id"] = BSON::ObjectId(conditions["_id"]) if conditions && conditions["_id"]

      if search == :all
        return nil_or_array(@collection.find(conditions).to_a)
      else
        return @collection.find_one(conditions)
      end
    end
    
    def save(cnf)
      # lookup database for solved cases
      old = find :one, { "cnf" => cnf["cnf"] }
      return old["_id"] if old

      if cnf["cnf"] =~ /and/ && cnf["cnf"] =~ /or/
        # use DPLL for preposition
        # TODO: set time limit
        kb = KnowledgeBase.new(cnf["cnf"])
        cnf["satisfiable"] = kb.dpll ? 1 : 0
        cnf["assignment"]  = kb.solution

      elsif cnf["cnf"] =~ /\s0$/
        # use minisat for dimacs
        # kb = KnowledgeBase.new(cnf["cnf"], :dimacs)
        # TODO: generate random file name
        File.open("/tmp/minisat.dimacs", 'w') {|f| f.write(cnf["cnf"]) }
        mini = `bin/minisat -cpu-lim=5 /tmp/minisat.dimacs /tmp/minisat.out`
        if mini =~ /UNSATISFIABLE/
          cnf["satisfiable"] = 0
        elsif mini =~ /SATISFIABLE/
          cnf["satisfiable"] = 1
          output = File.read("/tmp/minisat.out")
          output.slice!(0..2)
          output.slice!(output.length-2)
          cnf["assignment"] = output
        else
          cnf["satisfiable"] = 2
        end

      else
        return nil
      end

      @collection.save(cnf)
    end
    
    def delete(id)
      cnf = @collection.find_one({ "_id" => BSON::ObjectId(id) })
      @collection.remove(cnf) if cnf
    end
    
    private
    
      def stringify_keys(hash)
        hash.each_key do |key|
          hash[key.to_s] = hash.delete(key)
        end
        hash
      end
      
      def nil_or_array(result)
        result.size == 0 ? nil : result
      end
  end
end
