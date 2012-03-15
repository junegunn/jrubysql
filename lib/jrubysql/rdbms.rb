require 'jdbc-helper'

module JRubySQL
class RDBMS
  def self.get_type driver_or_type
    case driver_or_type.to_s.downcase
    when /oracle/
      :oracle
    when /mysql/
      :mysql
    when /postgres/
      :postgres
    when /sqlserver/
      :sqlserver
    else
      :unknown
    end
  end

  def initialize options
    @conn = 
      if options[:type]
        case options[:type]
        when :mysql
          JDBCHelper::MySQLConnector.connect(
            options[:host], options[:user], options[:password], options[:database])
        when :oracle
          host, svc = options[:host].split('/')
          if svc.nil?
            # FIXME
            raise ArgumentError.new "Oracle service name must be included in the hostname: e.g. localhost/orcl"
          end
          JDBCHelper::OracleConnector.connect(
            host, options[:user], options[:password], svc)
        when :postgres
          JDBCHelper::PostgresConnector.connect(
            options[:host], options[:user], options[:password], options[:database])
        when :sqlserver
          JDBCHelper::SqlServerConnector.connect(
            options[:host], options[:user], options[:password], options[:database])
        end
      elsif options[:driver]
        JDBCHelper::Connection.new(
          {
            :driver   => options[:driver],
            :url      => options[:url],
            :user     => options[:user],
            :password => options[:password]
          }.reject { |k, v| v.nil? }
        )
      else
        raise ArgumentError.new "Invalid connection specification"
      end
  end

  def autocommit
    @conn.java_obj.get_auto_commit
  end

  def autocommit= ac
    @conn.java_obj.set_auto_commit ac
  end

  def close
    @conn.close
  end

  def execute sql
    st = Time.now
    result = @conn.execute sql
    elapsed = Time.now - st

    {
      :set? => result.respond_to?(:each),
      :result => result,
      :elapsed => elapsed
    }
  end
end#RDBMS
end#JRubySQL