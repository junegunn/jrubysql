require 'rubygems'
require 'bundler'
ENV['BUNDLE_GEMFILE'] = File.join(File.dirname(__FILE__), '..', 'Gemfile')
Bundler.setup(:default, :development)
require 'test/unit'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

class TestJRubySQL < Test::Unit::TestCase
end
