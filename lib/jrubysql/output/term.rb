require 'erubis'
require 'tabularize'
require 'java'

module JRubySQL
module Output
class Term
  include JRubySQL::Messages

  HELP = Erubis::Eruby.new(File.read File.join(File.dirname(__FILE__), '../doc/help.txt.erb')).result(binding)

  def initialize
    # Make use of JLine included in JRuby
    java_import 'jline.Terminal'
    @terminal = Terminal.getTerminal
    trap 'INT' do
      Thread.main.raise Interrupt
    end
  end

  def welcome!
    puts JRubySQL.name
  end

  def cursor empty
    if empty
      'jrubysql> '
    else
      '       -> '
    end
  end

  def print_cursor empty
    print cursor(empty)
  end

  def print_help
    puts
    puts HELP
    puts
  end

  def info message
    puts "[I] #{message}"
  end

  def result message
    puts "[R] #{message}"
  end

  def warn message
    puts "[W] #{message}"
  end

  def error message
    puts "[E] #{message}"
  end

  def print_result ret
    # Footer
    elapsed = "(#{'%.2f' % ret[:elapsed]} sec)"

    if ret[:set?]
      begin
        cnt = print_table ret[:result]
        result m(:rows_returned, cnt, cnt > 1 ? 's' : '', elapsed)
      rescue Interrupt
        warn m(:interrupted)
      end
    elsif ret[:result]
      cnt = [0, ret[:result]].max
      result m(:rows_affected, cnt, cnt > 1 ? 's' : '', elapsed)
    else
      result elapsed
    end
    puts
  end

private
  def print_table ret, tabularize_opts = {}
    cnt = 0
    lines = [(@terminal.getTerminalHeight rescue JRubySQL::Constants::MAX_SCREEN_ROWS) - 5, 
             JRubySQL::Constants::MIN_SCREEN_ROWS].max
    cols = (@terminal.getTerminalWidth rescue nil)
    ret.each_slice(lines) do |slice|
      cnt += slice.length

      table = Tabularize.new tabularize_opts
      table << slice.first.labels.map { |l| decorate_label l }
      table.separator!
      slice.each do |row|
        table << row.to_a.map { |v| decorate v }
      end
      puts table
    end
    cnt
  end

  def decorate_label label
    label
  end

  def decorate value
    case value
    when BigDecimal
      value.to_s('F')
    else
      value.to_s
    end
  end
end#Term
end#Output
end#JRubySQL

