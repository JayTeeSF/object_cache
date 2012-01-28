# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "object_cache/version"

Gem::Specification.new do |s|
  s.name        = "object_cache"
  s.version     = ObjectCache::VERSION
  s.authors     = ["Jason Hoth Jr"]
  s.email       = ["jason_hoth_jr@his-service.net"]
  s.homepage    = ""
  s.summary     = %q{Simple Object store}
  s.description = %q{Simple Object store -- okay, it's a Hash}

  s.rubyforge_project = "object_cache"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rspec'

  # specify any dependencies here; for example:
  # s.add_runtime_dependency "rest-client"
end
