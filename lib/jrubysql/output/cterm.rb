require 'ansi'
require 'erubis'
require 'bigdecimal'

module JRubySQL
module Output
class CTerm < Term
  include ANSI::Code
  HELP = Erubis::Eruby.new(File.read File.join(File.dirname(__FILE__), '../doc/help.txt.erb')).result(binding)

  def welcome!
    puts bold + JRubySQL.name + reset
  end

  def cursor empty
    if empty
      wrap('jrubysql', bold) + 
            wrap('> ', bold + green)
    else
      wrap('       -', bold + yellow) +
            wrap('> ', bold + red)
    end
  end

  def print_cursor empty
    print cursor(empty)
  end

  def print_help
    puts
    puts wrap(HELP, blue + bold)
    puts
  end

  def info message
    col = blue + bold
    puts wrap(message, col)
  end

  def result message
    col = green
    puts wrap(message, green)
  end

  def warn message
    col = yellow + bold
    puts wrap(message, col)
  end

  def error message
    col = red + bold
    puts wrap(message, col)
  end

private
  def separator_for row
    # 13-bytes for ANSI codes
    # - bold/reset: 4
    # - colors: 5
    '+-' + row.map { |e| '-' * (e.length - 13) }.join('-+-') + '-+'
  end

  def decorate_label label
    white + bold + label + reset
  end

  # This looks stupid though.
  def decorate value
    case value
    when BigDecimal
      cyan + value.to_s('F') + reset + reset
    when Numeric
      cyan + value.to_s + reset + reset
    when String
      yellow + value + reset + reset
    when Time, Java::JavaSql::Timestamp
      magenta + value.to_s + reset + reset
    when NilClass
      bold + red + '(null)' + reset
    else
      white + reset + value.to_s + reset
    end
  end

  def cnow
    green + now + reset
  end

  def wrap text, color
    color + text + reset
  end
    
end#CTerm
end#Output
end#JRubySQL
