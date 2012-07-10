require 'ansi'
require 'erubis'
require 'bigdecimal'

module JRubySQL
module Output
class CTerm < Term
  include ANSI::Code

  attr_reader :colors

  def initialize colors
    super()

    @colors =
        YAML.load(
          File.read(
            File.join(
              File.dirname(__FILE__), "color_scheme/default.yml"))).merge(colors || {})

    @ccode = @colors.inject(Hash.new('')) { |h, pair| 
      k, v = pair
      h[k.to_sym] = v.strip.split(/\s+/).map { |code| ANSI::Code.send(code) rescue '' }.join
      h
    }
  end

  def welcome!
    puts bold + JRubySQL.name + reset
  end

  def cursor empty
    if empty
      wrap('jrubysql', @ccode[:prompt1]) + 
            wrap('> ', @ccode[:prompt2])
    else
      wrap('       -', @ccode[:prompt3]) +
            wrap('> ', @ccode[:prompt4])
    end
  end

  def print_cursor empty
    print cursor(empty)
  end

  def print_help
    puts
    puts wrap(HELP, @ccode[:help])
    puts
  end

  def info message
    puts wrap(message, @ccode[:info])
  end

  def result message
    puts wrap(message, @ccode[:result])
  end

  def warn message
    puts wrap(message, @ccode[:warning])
  end

  def error message
    puts wrap(message, @ccode[:error])
  end

private
  def print_table ret
    super ret, {
      :hborder => @ccode[:border] + '-',
      :vborder => wrap('|', @ccode[:border]),
      :iborder => wrap('+', @ccode[:border]),
    }
  end

  def decorate_label label
    wrap(label, @ccode[:label])
  end

  # This looks stupid though.
  def decorate value
    case value
    when BigDecimal
      wrap(value.to_s('F'), @ccode[:number])
    when Numeric
      wrap(value.to_s, @ccode[:number])
    when String
      wrap(value, @ccode[:string])
    when Time, Java::JavaSql::Timestamp
      wrap(value.to_s, @ccode[:time])
    when NilClass
      wrap('(null)', @ccode[:nil])
    else
      wrap(value.to_s, @ccode[:default])
    end
  end

  def wrap text, color
    color + text + (reset unless color.empty?)
  end
    
end#CTerm
end#Output
end#JRubySQL
