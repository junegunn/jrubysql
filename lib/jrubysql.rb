require "jrubysql/version"

if RUBY_PLATFORM.match(/java/).nil?
  puts 'Sorry. jrubysql only runs on JRuby.'
  exit 1
end

require 'jrubysql/messages'
require 'jrubysql/config'
require 'jrubysql/constants'
require 'jrubysql/rdbms'
require 'jrubysql/option_parser'
require 'jrubysql/input/input'
require 'jrubysql/input/console'
require 'jrubysql/input/file'
require 'jrubysql/output/base'
require 'jrubysql/output/csv'
require 'jrubysql/output/term'
require 'jrubysql/output/cterm'
require 'jrubysql/controller'

module JRubySQL
  def self.name
    "JRubySQL #{JRubySQL::VERSION}"
  end

  def self.launch argv
    if argv.empty?
      JRubySQL::Controller.new(nil, nil).start
    else
      argv_str = argv.join(' ')
      options = JRubySQL::OptionParser.parse argv
      JRubySQL::Controller.new(options, argv_str).start
    end
  end
end

