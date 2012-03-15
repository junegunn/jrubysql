require 'each_sql'

module JRubySQL
module Input
class File
  def initiailze controller, file_path
    @controller = controller
    script = File.read(file_path)

    @sqls  = EachSQL(script, JRubySQL::Input.get_each_sql_type(@controller.db_type))
  end

  def get
    { :sqls => @sqls }
  end
end#Console
end#Input
end#JRubySQL

