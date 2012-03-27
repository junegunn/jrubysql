require 'rubygems'
require 'bundler'
ENV['BUNDLE_GEMFILE'] = File.join(File.dirname(__FILE__), '..', 'Gemfile')
Bundler.setup(:default, :development)
require 'test/unit'
require 'mocha'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'jrubysql'

module JRubySQLTestHelper
  JRubySQL::Constants.const_set :DEFAULT_RC_PATH, '/tmp/.jrubysqlrc'

  def capture &block
    begin
      $stdout = StringIO.new
      $stderr = StringIO.new

      begin
        ret = block.call
      rescue SystemExit => x
        ret = x.status
      end

      return {
        :stdout => $stdout.string,
        :stderr => $stderr.string, 
        :return => ret
      }
    ensure
      $stdout = STDOUT
      $stderr = STDERR
    end
  end
end
