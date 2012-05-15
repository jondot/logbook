# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "logbook/version"

Gem::Specification.new do |s|
  s.name        = "lg"
  s.version     = Logbook::VERSION
  s.authors     = ["Dotan Nahum"]
  s.email       = ["jondotan@gmail.com"]
  s.homepage    = "http://jondot.github.com/logbook/"
  s.summary     = %q{log your memories onto virtual logbooks made of Gists}
  s.description = %q{log your memories onto virtual logbooks made of Gists}

  s.rubyforge_project = "lg"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rr"
  s.add_development_dependency "fakefs"
  s.add_development_dependency "guard-minitest"
  s.add_runtime_dependency "user_config"
  s.add_runtime_dependency "thor"
  s.add_runtime_dependency "chronic"

end
