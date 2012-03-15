require 'optparse'
require 'highline'

module JRubySQL
module OptionParser
  def self.parse argv
    {:color => true}.tap do |options|
      opts = ::OptionParser.new { |opts|
        opts.banner = 
          [
            "usage: jrubysql [options]",
            "       jrubysql -t DBMS_TYPE -h HOSTNAME [-u USERNAME -p [PASSWORD] [-d DATABASE]] [-f FILENAME]",
            "       jrubysql -c CLASSNAME -j JDBC_URL [-u USERNAME -p [PASSWORD] [-d DATABASE]] [-f FILENAME]"
          ].join($/)
        opts.separator ''

        opts.on('-t', '--type DBMS_TYPE', 'Database type: mysql/oracle/postgres/sqlserver') do |v|
          options[:type] = v.downcase.to_sym
        end

        opts.on('-h', '--host HOST', 'DBMS host address') do |v|
          options[:host] = v
        end
      
        opts.on('-c', '--class-name CLASSNAME', 'Class name of the JDBC driver') do |v|
          options[:driver] = v
        end

        opts.on('-d', '--database DATABASE', 'Name of the database (optional)') do |v|
          options[:database] = v
        end

        opts.on('-j', '--jdbc-url JDBC_URL', 'JDBC URL for the connection') do |v|
          options[:url] = v
        end
      
        opts.on('-u', '--user USERNAME', 'Username') do |v|
          options[:user] = v
        end
      
        opts.on('-p', '--password [PASSWORD]', 'Password') do |v|
          options[:password] = v
        end
      
        opts.on('-f', '--filename FILENAME', 'SQL script file') do |v|
          options[:filename] = v
        end

        opts.on('--no-color', 'Suppress ANSI color codes in output') do |v|
          options[:color] = v
        end
      
        opts.on_tail('--help', "Show this message") do
          puts opts
          exit
        end
      }
      begin
        opts.parse! argv
        if options.has_key?(:password) && options[:password].nil?
          options[:password] = ask_password
        end

        validate options
      rescue Exception => e
        puts e.to_s
        puts '=' * e.to_s.length
        puts opts
        exit
      end
    end#tap
  end

private
  def self.validate opts
    # Driver or Type
    # Host or JDBC_URL

    if (!opts[:type] && !opts[:driver]) || (opts[:type] && opts[:driver])
      raise ArgumentError.new 'Invalid connection specification'
    end

    unless (opts[:type] && opts[:host]) || (opts[:driver] && opts[:url])
      raise ArgumentError.new 'Invalid connection specification.'
    end

    if opts[:type] && !JRubySQL::Constants::SUPPORTED_DBMS_TYPES.include?(opts[:type])
      raise ArgumentError.new "#{opts[:type]} is not supported yet. Try with -c and -j options instead"
    end

  end

  def self.ask_password
    HighLine.new.ask("Password: " ) { |q| q.echo = "*" }
  end

end#OptionParser
end#JRubySQL

# p JRubySQL::OptionParser.parse %w[-h aa gg -t asdfa -p]
