require 'spec_helper'
require 'gist_store/gist_store'

def stamp
  @stamp ||= DateTime.new(1981,9,8)
end

describe Logbook::GistStore do
  it "should get content" do
    mock(Gist).read_raw('bid') {
      {
        'files' => {
          '19810908' => {
            'content' => "hello world"
          }
        }
      }
    }

    g = Logbook::GistStore.new
    g.get('bid', stamp).must_equal "hello world"
  end

  it "should create" do
    mock(Gist).write(
      [{
        :input => "hello world",
        :filename => "cover",
        :extension => "txt"
      }],
        true
    ){
      "http://example.com/id"
    }

    g = Logbook::GistStore.new
    g.create("hello world")
  end

  it "should list all" do
    mock(Gist).read_raw('bid'){
      {
        'files' => {
          '19810908' => {
            'filename' => '19810908',
            'content' => "hello world"
          },
          'cover' => {
            'filename' => 'cover',
            'content' => "my book"
          }
        }
      }
    }

    g = Logbook::GistStore.new
    book = g.all('bid')

    book.must_equal(
      {
        :id => 'bid',
        :cover => 'my book',
        :entries => [{:date => DateTime.strptime("19810908", "%Y%m%d"), :content => 'hello world'}]
      }
    )
  end

  it "should be invalid when env variables are not set" do
    ENV['GITHUB_USER'] = nil
    ENV['GITHUB_PASSWORD'] = nil

    g = Logbook::GistStore.new
    g.valid?.must_equal false
    g.error.must_match /Please set up/
  end

    it "should be valid when env variables are set" do
    ENV['GITHUB_USER'] = 'ghuser'
    ENV['GITHUB_PASSWORD'] = 'ghpwd'

    g = Logbook::GistStore.new
    g.valid?.must_equal true
  end

end

