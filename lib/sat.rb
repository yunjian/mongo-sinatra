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
      kb = KnowledgeBase.new(cnf["cnf"])
      cnf["satisfiable"] = kb.dpll
      cnf["assignment"]  = kb.solution
      return @collection.save(cnf)
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
