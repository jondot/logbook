require 'spec_helper'
require 'logbook'

def stamp
  @stamp ||= Time.new(1981, 9, 8)
end

  describe Logbook::Book do
  
    it "should create and add an entry given no page existed" do
      gs= Object.new
      Logbook.store = gs
   
     stub(gs).valid?{ true }
     mock(gs).create("The Neverending Story") { "book-id" }
      mock(gs).get("book-id", stamp) { nil }
      mock(gs).update("book-id", stamp, "testing 123") { stamp }

      @bk = Logbook::Book.new
      @bk.create "The Neverending Story"
      @bk.add(stamp, "testing 123")
    end

    it "should add an entry given a page existed" do
      gs= Object.new
      Logbook.store = gs
      stub(gs).valid?{ true }
      mock(gs).create("#{ENV['USER']}'s log.") { "book-id" }
      mock(gs).get("book-id", stamp) { "testing 123" }
      mock(gs).update("book-id", stamp, "testing 123\ntesting 456") { stamp }

      @bk = Logbook::Book.new
      @bk.create
      @bk.add(stamp, "testing 456")
    end

    it "should get an entry" do
      gs= Object.new
      Logbook.store = gs

      @bk = Logbook::Book.new('book-id')
      mock(gs).valid?{ true }
      mock(gs).get("book-id", stamp) { "testing 123" }

      @bk.get(stamp).must_equal "testing 123"
    end


    it "Should fetch all of the book" do
      gs= Object.new
      Logbook.store = gs

      @bk = Logbook::Book.new('book-id') 
      stub(gs).valid?{ true }
      mock(gs).all('book-id') { 
        {
         :cover =>  "The Neverending Story",
         :entries => [{
            :content => "testing 123\ntesting 456",
            :date => stamp
          }]
        }
      }

      book = @bk.all
      book[:cover].must_equal "The Neverending Story"
      book[:entries].count.must_equal 1 # excluding book cover file
      book[:entries][0][:content].must_equal "testing 123\ntesting 456"
      book[:entries][0][:date].must_equal stamp
    end

    it "should handle store not being valid" do
      gs= Object.new
      Logbook.store = gs

      @bk = Logbook::Book.new('book-id') 
      stub(gs).valid?{ false }
      stub(gs).error{ "test error" }

      proc { @bk.all }.must_raise RuntimeError, "test error"
    end
end
