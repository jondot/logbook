require 'gist_store/gist'

module Logbook
 class GistStore
    DATE_FMT = "%Y%m%d".freeze
    attr_reader :error

    def initialize
      @valid = !!(ENV['GITHUB_USER'] && ENV['GITHUB_PASSWORD'])
      @error = @valid ? '' : "Please set up GITHUB_USER and GITHUB_PASSWORD in your env."
    end

    def valid?
      @valid
    end
    
    def get(id, time)
      gist = Gist.read_raw(id)
      return nil unless gist
      file = gist['files'][gist_file(time)]
      return nil unless file
      file['content']
    end

    def create(covertext)
      u = URI.parse Gist.write(gist_data(covertext, "cover"), true)
      u.path[1..-1]
    end

    def update(id, time, page)
      Gist.update(id, gist_data(page, gist_file(time)))
    end

    def all(id)
      gist = Gist.read_raw(id)
      return nil unless gist

      entries = gist['files'].reject{|k|  ["cover"].include? k }.map do |fname, v|
        { :date    => DateTime.strptime(v['filename'], DATE_FMT),
          :content => v['content'] }
      end

      { :id => id,
        :cover => gist['files']['cover']['content'],
        :entries => entries }
    end

    def destroy(id)
      Gist.delete(id)
    end

  private
    def gist_file(time)
      time.strftime DATE_FMT
    end

    def gist_data(text, fname)
      [{:input => text, :filename => fname, :extension => "txt"}]
    end

  end
end
