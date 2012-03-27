require 'optparse'
require 'highline'

module JRubySQL
module OptionParser
  class << self
    include JRubySQL::Messages
  end

  def self.parse argv
    {:output => 'cterm'}.tap do |options|
      opts = ::OptionParser.new { |opts|
        opts.banner = 
          [
            "usage: jrubysql [options]",
            "       jrubysql -t DBMS_TYPE -h HOSTNAME [-u USERNAME] [-p [PASSWORD]] [-d DATABASE]",
            "       jrubysql -c CLASSNAME -j JDBC_URL [-u USERNAME] [-p [PASSWORD]] [-d DATABASE]"
          ].join($/)
        opts.separator ''

        opts.on('-t', '--type DBMS_TYPE', 'Database type: mysql/oracle/postgres/sqlserver/sqlite') do |v|
          options[:type] = v.downcase.to_sym
        end

        opts.on('-h', '--host HOST', 'DBMS host address') do |v|
          options[:host] = v
        end

        opts.separator ""
      
        opts.on('-c', '--class-name CLASSNAME', 'Class name of the JDBC driver') do |v|
          options[:driver] = v
        end

        opts.on('-j', '--jdbc-url JDBC_URL', 'JDBC URL for the connection') do |v|
          options[:url] = v
        end

        opts.separator ""
      
        opts.on('-u', '--user USERNAME', 'Username') do |v|
          options[:user] = v
        end
      
        opts.on('-p', '--password [PASSWORD]', 'Password') do |v|
          options[:password] = v
        end
      
        opts.on('-d', '--database DATABASE', 'Name of the database (optional)') do |v|
          options[:database] = v
        end

        opts.separator ""

        opts.on('-f', '--filename FILENAME', 'SQL script file') do |v|
          options[:filename] = v
        end

        opts.on('-e', '--execute SQLSCRIPT', 'SQL script') do |v|
          options[:script] = v
        end

        opts.on('-o', '--output OUTPUT_TYPE', 'Output type: cterm|term|csv (default: cterm)') do |v|
          options[:output] = v
        end
      
        opts.separator ""

        opts.on_tail('--help', "Show this message") do
          puts opts
          exit
        end

        opts.on_tail('--version', "Show version") do
          puts JRubySQL.name
          exit
        end
      }
      begin
        opts.parse! argv
        if options.has_key?(:password) && options[:password].nil?
          options[:password] = ask_password
        end

        validate options
      rescue SystemExit
        exit 0
      rescue Exception => e
        puts e.to_s
        puts '=' * e.to_s.length
        puts opts
        exit 1
      end
    end#tap
  end

private
  def self.validate opts
    unless %w[cterm term csv].include?(opts[:output])
      raise ArgumentError.new m(:invalid_output)
    end

    if opts[:script] && opts[:filename]
      raise ArgumentError.new m(:both_script_and_filename)
    end

    if (!opts[:type] && !opts[:driver]) || (opts[:type] && opts[:driver])
      raise ArgumentError.new m(:invalid_connection)
    end

    unless (opts[:type] && opts[:host]) || (opts[:driver] && opts[:url])
      raise ArgumentError.new m(:invalid_connection)
    end

    if opts[:type] && !JRubySQL::Constants::SUPPORTED_DBMS_TYPES.include?(opts[:type])
      raise ArgumentError.new m(:unsupported_database, opts[:type])
    end

    if opts[:filename] && !File.exists?(opts[:filename])
      raise ArgumentError.new m(:file_not_found, opts[:filename])
    end

  end

  def self.ask_password
    HighLine.new.ask(m(:ask_password)) { |q| q.echo = "*" }
  end

end#OptionParser
end#JRubySQL

# p JRubySQL::OptionParser.parse %w[-h aa gg -t asdfa -p]
