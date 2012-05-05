require 'gist_store/gist_store'

module Logbook
  def self.store
    @store ||= GistStore.new
  end
  def self.store=(store)
    @store = store
  end
end

require "logbook/version"
require 'logbook/book'

