module JRubySQL
module Constants
  SUPPORTED_DBMS_TYPES = [ :mysql, :oracle, :postgres, :sqlserver, :sqlite ]

  # .jrubysqlrc
  DEFAULT_RC_PATH        = File.join(ENV['HOME'], '.jrubysqlrc')
  MAX_CONNECTION_HISTORY = 10
  # MAX_COMMAND_HISTORY    = 100

  # Terminal (TBD)
  # MAX_COLUMN_WIDTH = 80
  MIN_SCREEN_ROWS  = 10
  MAX_SCREEN_ROWS  = 50

end#Constants
end#JRubySQL
