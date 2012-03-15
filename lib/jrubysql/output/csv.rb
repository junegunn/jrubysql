require 'csv'

module JRubySQL
module Output
class CSV
  def welcome!;   end
  def info   msg
    $stderr.puts "[I] #{msg}"
  end
  def result msg
    $stderr.puts "[R] #{msg}"
  end
  def warn   msg
    $stderr.puts "[W] #{msg}"
  end
  def error  msg
    $stderr.puts "[E] #{msg}"
  end
  def print_help; end

  def cursor empty
    ''
  end

  def print_cursor empty; end

  def print_result ret
    # Footer
    elapsed = "(#{'%.2f' % ret[:elapsed]} sec)"

    if ret[:set?]
      ret[:result].each_with_index do |row, idx|
        puts ::CSV.generate_line(row.labels) if idx == 0
        puts ::CSV.generate_line row.map { |col|
          case col
          when BigDecimal
            col.to_s('F')
          else
            col
          end
        }
      end
    end
  end

end#CSV
end#Output
end#JRubySQL

