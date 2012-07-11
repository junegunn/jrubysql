require 'each_sql'

module JRubySQL
module Input
class Script
  def initialize controller, script
    @controller = controller
    sqls  = EachSQL(script, JRubySQL::Input.get_each_sql_type(@controller.db_type))
    @ret = { :sqls => sqls, :history => false }
  end

  def prepare sqls
    # No-op
  end

  def get
    @ret.tap { @ret = { :commands => [{ :quit => nil }, nil] } }
  end
end#Console
end#Input
end#JRubySQL

