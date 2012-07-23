# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "jrubysql/version"

Gem::Specification.new do |s|
  s.name        = "jrubysql"
  s.version     = JRubySQL::VERSION
  s.authors     = ["Junegunn Choi"]
  s.email       = ["junegunn.c@gmail.com"]
  s.homepage    = "https://github.com/junegunn/jrubysql"
  s.summary     = %q{SQL client for any JDBC-compliant database.}
  s.description = %q{SQL client for any JDBC-compliant database. Written in JRuby.}

  s.rubyforge_project = "jrubysql"

  s.files         = `git ls-files`.split("\n").reject { |f| f =~ /^screenshots/ }
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "test-unit"
  s.add_development_dependency "mocha", '~> 0.11.0'
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-test"

  s.add_runtime_dependency "jdbc-helper", '~> 0.7.4'
  s.add_runtime_dependency "insensitive_hash", '~> 0.2.4'
  s.add_runtime_dependency "tabularize", '~> 0.2.4'
  s.add_runtime_dependency "each_sql", '~> 0.3.1'
  s.add_runtime_dependency "highline", '~> 1.6.11'
  s.add_runtime_dependency "ansi", '~> 1.4.2'
  s.add_runtime_dependency "erubis", '~> 2.7.0'
end
