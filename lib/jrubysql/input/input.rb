require 'each_sql'

module JRubySQL
module Input
  def self.get_each_sql_type db_type
    {
      :mysql => :mysql,
      :oracle => :oracle,
      :postgres => :postgres
    }[db_type] || :default
  end

  def self.get_parser db_type, delimiter = ';'
    EachSQL.new(get_each_sql_type(db_type), delimiter)
  end
end#Input
end#JRubySQL
