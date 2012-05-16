require 'spec_helper'
require 'logbook/cli'


def stamp
  @stamp ||= DateTime.new(1981,9,8)
end
describe Logbook::CLI do
  before do
   FakeFS.activate!
   FakeFS::FileSystem.clear
  end
  after do
   FakeFS.deactivate!
   FakeFS::FileSystem.clear
  end

  it "should show indicate no book is set on fresh env" do
    out = capture_io{ Logbook::CLI.start ['book?'] }.join ''
    out.must_match /No book is set. Create one/
  end


  it "should not add when no book" do
    out = capture_io{ Logbook::CLI.start %w{ add so long, and thanks for all the fish. } }.join ''
    out.must_match /No book is set./
  end

  it "should create a book given nothing is set and we call book" do
    any_instance_of(Logbook::CLI) do |cli|
      mock(cli).yes?(anything){ true }
    end
    book = mock(Object).create('Robinson') { 'deadbeef' }
    mock(Logbook::Book).new{ book }

    out = capture_io{ Logbook::CLI.start ['book', 'Robinson'] }.join ''

    out.must_match /Robinson/
  end

  it "should create a book given nothing is set and we call book" do
    any_instance_of(Logbook::CLI) do |cli|
      mock(cli).yes?(anything){ true }
    end
    book = mock(Object).create('Robinson') { 'deadbeef' }
    mock(Logbook::Book).new{ book }

    out = capture_io{ Logbook::CLI.start ['book', 'Robinson'] }.join ''

    out.must_match /Robinson/
  end

  describe "given errornous book" do
    before do
      any_instance_of(Logbook::Book) do |ins|
        stub(ins).create(anything){ raise "error" }
        stub(ins).add_temporal(anything){ raise "error" }
        stub(ins).all{ raise "error" }
      end
      any_instance_of(Logbook::CLI) do |cli|
        stub(cli).current_book{ Logbook::Book.new 'id' }
      end
    end

    it "should error when trying to create a new book" do
      any_instance_of(Logbook::CLI) do |cli|
        mock(cli).yes?(anything){ true }
      end

      out = capture_io{ Logbook::CLI.start ['book', 'Robinson'] }.join ''
      out.must_match /error/
    end

    it "should error when adding" do
      out = capture_io{ Logbook::CLI.start ["add","so long, and thanks for all the fish."] }.join ''
      out.must_match /error/
    end

    it "should error when listing" do
      out = capture_io{ Logbook::CLI.start ["all"] }.join ''
      out.must_match /error/
    end

  end



  describe "given a book" do
    before do
      u = UserConfig.new(".logbook")
      u['logbook.yaml'][:current_book] = "deadbeef"
      u['logbook.yaml'][:books] = {
          "deadbeef" => "Captain's log, stardate 3323426-0",
          "c0debabe" => "The log"
        }
      u['logbook.yaml'].save
    end

    it "should show current book" do
      out = capture_io{ Logbook::CLI.start ['book?'] }.join ''
      out.must_match /Captain's log, stardate/
    end

    it "should add to book" do
      book = mock(Object).add_temporal(anything) { stamp }

      # thor is being a bit hard here. since it's static, and
      # it won't even give pass through dispatch/invoke instance
      # methods, we're going to be dirty and mock ctors :(
      mock(Logbook::Book).new("deadbeef") { book }

      out = capture_io{ Logbook::CLI.start ["add","so long, and thanks for all the fish."] }.join ''
      out.must_match /OK, at.*1981-09-08/
    end

    it "should switch a book directly given an id" do
      out = capture_io{ Logbook::CLI.start ["book","c0debabe"] }.join ''
      out.must_match /switched/
    end

    it "should provide an option to pick a book from a menu" do
      any_instance_of(Logbook::CLI) do |cli|
        mock(cli).ask(anything){ "2" }
      end
      out = capture_io{ Logbook::CLI.start ["book"]}.join ''
      
      lines = out.lines.to_a
      lines[0].must_match /1  deadbeef  Captain's log, stardate 3323426-0\n/
      lines[1].must_match /2  c0debabe  The log/
      lines[2].must_match /OK, selected/
    end
  end
end

