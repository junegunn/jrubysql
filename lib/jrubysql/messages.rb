require 'yaml'
require 'insensitive_hash/minimal'

module JRubySQL
module Messages
  def m *args
    args = args.dup
    type = args.shift
    msg = MESSAGES[type]
    args.each do |arg|
      msg = msg.sub('$$', arg.to_s)
    end
    msg
  end

private
  MESSAGES = 
    InsensitiveHash[
      YAML.load(File.read File.join( File.dirname(__FILE__), 'messages.yml' ))
    ].tap { |ih| ih.underscore = true }
end#Messages
end#JRubySQL

