
require 'date'
require 'chronic'
require 'gist_store/gist_store'

module Logbook
  class Book
    attr_reader :id
    attr_accessor :store


    def initialize(id=nil)
      @id = id
      @store = Logbook.store
    end

    def create(covertext=nil)
      store_available

      cover = covertext || "#{ENV['USER'] || 'Captain'}'s log."
      @id = store.create cover
    end

    def add_temporal(text)
      temporal = false

      time = nil
      if text =~ /(.+?)\s*:\s*(.*)/
        time = Chronic.parse($1)
        text = $2 if time
        temporal = true if time
      end

      time ||= Time.now

      add time, text
    end

    def add(time, text)
      store_available
      must_exist

      page = get(time)
      store.update(id, time, "#{page ? "#{page}\n" : ""}#{text}")
      time
    end

    def get(time)
      store_available
      must_exist

      page = store.get(id, time)
    end


    def all
      store_available
      must_exist
      
      store.all(id)
    end
  
    def destroy
      store_available
      must_exist

      store.destroy(id)
    end

    def store_available
      raise store.error unless store.valid?
    end

    def must_exist
      raise "create a book first" unless @id
    end
  end

end
