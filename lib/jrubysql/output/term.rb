require 'erubis'
require 'tabularize'
require 'java'
java_import 'jline.Terminal'
trap 'INT' do
  Thread.main.raise Interrupt
end

module JRubySQL
module Output
class Term < JRubySQL::Output::Base
  HELP = Erubis::Eruby.new(File.read File.join(File.dirname(__FILE__), '../doc/help.txt.erb')).result(binding)

  def initialize controller
    @controller = controller
    @terminal   = Terminal.getTerminal
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
        result "#{cnt} rows. #{elapsed}"
      rescue Interrupt
        warn "Interrupted."
      end
    elsif ret[:result]
      result "#{[0, ret[:result]].max} rows affected. #{elapsed}"
    else
      result elapsed
    end
  end

private
  def print_table ret
    cnt = 0
    lines = [(@terminal.getTerminalHeight rescue JRubySQL::Constants::MAX_SCREEN_ROWS) - 5, 
             JRubySQL::Constants::MIN_SCREEN_ROWS].max
    ret.each_slice(lines) do |slice|
      cnt += slice.length

      table = [slice.first.labels.map { |l| decorate_label l }] + 
          slice.map { |row| row.to_a.map { |v| decorate v } }

      output = Tabularize.it(table, :unicode_display => true)
      separator = separator_for(output.first)
      output_strs = output.map { |r| '| ' + r.join(' | ') + ' |' }
      [0, 2, -1].each { |l| output_strs.insert l, separator }
      puts output_strs
    end
    cnt
  end

  def separator_for row
    '+-' + row.map { |e| '-' * e.length }.join('-+-') + '-+'
  end

  def decorate_label label
    label
  end

  def decorate value
    value.to_s
  end

  def now
    Time.now.strftime('%Y/%m/%d %H:%M:%S')
  end
end#Term
end#Output
end#JRubySQL

