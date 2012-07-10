require 'readline'

module JRubySQL
module Input
class Console
  def initialize controller
    @controller = controller
    @esql = JRubySQL::Input.get_parser @controller.db_type
  end

  def prepare sqls
    sqls.each do |sql|
      Readline::HISTORY << sql
    end
  end

  def get
    empty_response = { :sqls => [], :commands => [] }
    line = Readline::readline(@controller.cursor(@esql.empty?), false)

    return(
      # CTRL-D
      if line.nil?
        puts
        @esql.clear
        empty_response
      # Empty input (not inside a block)
      elsif @esql.empty? && line.gsub(/\s/m, '').empty?
        empty_response
      # Console commands
      elsif @esql.empty? && cmd = process_command(line)
        { :commands => [cmd, line] }
      # Line with delimiters
      elsif line.include?(@esql.delimiter)
        @esql << line + $/
        result = @esql.shift
        result[:sqls].each do |sql|
          Readline::HISTORY << sql + @esql.delimiter
        end
        { :sqls => result[:sqls], :delimiter => @esql.delimiter }
      # SQL without delimiter
      else
        @esql << line + $/
        empty_response
      end
    )
  end

  def delimiter
    @esql.delimiter
  end

  def delimiter= delim
    @esql.delimiter = delim
  end

private

  def process
    result = @esql.shift
    result[:sqls].each do |sql|
      Readline::HISTORY << sql + ';'
      @controller.execute sql
    end
  end

  def process_command line
    Readline::HISTORY << line
    case line.chomp.downcase.strip
    when /^help(#{Regexp.escape delimiter})?$/
      { :help => nil }
    when /^delimiter (\S+$)/
      { :delimiter => $1 }
    when 'autocommit'
      { :autocommit => nil }
    when /^autocommit (\S+?)(#{Regexp.escape delimiter})?$/
      { :autocommit => $1 }
    when 'now'
      { :now => nil }
    when /^(exit|quit)(#{Regexp.escape delimiter})?$/
      { :quit => nil }
    else
      Readline::HISTORY.pop
      nil
    end
  end
end#Console
end#Input
end#JRubySQL

