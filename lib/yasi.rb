require 'uri'
require 'mongo'

module Yasi
  class << self
    def connect
      uri = URI.parse(ENV['MONGOHQ_URL'])
      conn = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
      @db = conn.db(uri.path.gsub(/^\//, ''))
      @collection = @db.collection("yasis")
    end
    
    def find(search)
      if search == :all
        return nil_or_array(@collection.find.to_a)
      else
        return find_with_criteria(search)
      end
    end
    
    def save(yasi)
      @collection.save(yasi)
    end
    
    def delete(id)
      yasi = @collection.find_one(BSON::ObjectID(id))
      @collection.remove(yasi) if yasi
    end
    
    private
    
      def find_with_criteria(search)
        stringify_keys(search)
        if search["author"]
          author = @db.collection("author").find_one stringify_keys(search["author"])
          return nil_or_array( @collection.find(author).to_a ) if author
        else
          return nil_or_array( @collection.find(search).to_a )
        end
      end
      
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