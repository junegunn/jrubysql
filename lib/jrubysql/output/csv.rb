require 'csv'

module JRubySQL
module Output
class CSV < JRubySQL::Output::Base
  def feed_label labels
    put_row labels
  end

  def feed_row row
    CSV.generate_line row
  end

  def feed_footer; end
end#CSV
end#Output
end#JRubySQL

