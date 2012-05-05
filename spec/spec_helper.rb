#require 'simplecov'
#SimpleCov.start if ENV["COVERAGE"]

require 'minitest/autorun'



require 'rr'
require 'fakefs/safe'
require 'user_config'


class MiniTest::Unit::TestCase
  include RR::Adapters::MiniTest
end

def file_content(file)
  File.read(File.expand_path("files/"+file, File.dirname(__FILE__)))
end

require 'thor'
# This is to silence the 'task' warning for the mocks.
#
class Thor
  class << self
    def create_task(meth) #:nodoc:
      if @usage && @desc
        base_class = @hide ? Thor::HiddenTask : Thor::Task
        tasks[meth] = base_class.new(meth, @desc, @long_desc, @usage, method_options)
        @usage, @desc, @long_desc, @method_options, @hide = nil
        true
      elsif self.all_tasks[meth] || meth == "method_missing"
        true
      else
        false
      end
    end
  end
end

# UserConfig does chmod
module FakeFS::FileUtils
  def chmod(f, m)
  end
end

# FakeFS does not fake Kernel.open
class UserConfig::YAMLFile
    def save
      unless File.exist?((dir = File.dirname(path)))
        FileUtils.mkdir_p(dir)
      end
      #replace Kernel.open with File.open
      File.open(path, 'w') do |f|
        YAML.dump(@cache, f)
      end
    end
end
