require 'quote_unquote'

module JRubySQL
class Controller
  attr_reader :db_type

  def initialize options, argv_str
    @config = JRubySQL::Config.new
    histories = @config['history']

    if options.nil?
      if histories.nil? || histories.empty?
        JRubySQL::OptionParser.parse []
      else
        # FIXME: Output
        puts "Parameter not given. Choose one:"
        histories.each_with_index do |history, idx|
          puts "[#{idx + 1}] #{history.first}"
        end
        print '> '
        select = $stdin.gets
        select = select && select.chomp
        if (1..(histories.length)).include?(select.to_i)
          history = histories[select.to_i - 1]
          @options = history.last
          @argv_str = history.first
        else
          puts
          JRubySQL::OptionParser.parse []
        end
      end
    else
      @options = options
      @argv_str = argv_str
    end

    @db_type = JRubySQL::RDBMS.get_type(@options[:type] || @options[:driver])

    # Setting up input: file or console (and more?)
    if @options[:filename]
      @input = JRubySQL::Input::File.new(self, @options[:filename])
    else
      @input = JRubySQL::Input::Console.new(self)
    end

    # Setting up output: Colored terminal 
    if @options[:color]
      @output = JRubySQL::Output::CTerm.new(self)
    else
      @output = JRubySQL::Output::Term.new(self)
    end
  end

  def start
    @output.welcome!
    @output.info "Connecting to the database ..."
    begin
      @rdbms = JRubySQL::RDBMS.new @options
    rescue Exception => e
      @output.error e.to_s
      exit 1
    end
    @output.info "Connected."

    history = @config['history'] || []
    history.unshift [@argv_str, @options]
    history.uniq!
    if history.length > JRubySQL::Constants::MAX_CONNECTION_HISTORY
      history = history[0, JRubySQL::Constants::MAX_CONNECTION_HISTORY]
    end
    @config['history'] = history

    loop do
      ret = @input.get

      ret[:sqls].each do |sql|
        begin
          output @rdbms.execute(sql)
        rescue Exception => e
          @output.error e.to_s
        end
      end if ret.has_key?(:sqls)

      ret[:commands].each do |command|
        process_command command.keys.first, command.values.first
      end if ret.has_key?(:commands)
    end
  end

  def cursor empty = true
    @output.cursor empty
  end

  def print_cursor empty = true
    @output.print_cursor empty
  end

private
  def output result
    @output.print_result result
  end

  def process_command cmd, params
    case cmd
    when :help
      @output.print_help
    when :quit
      @output.info "Goodbye!"
      quit!
    when :delimiter
      @output.info "Setting delimiter to #{params}"
      @input.delimiter = params
    when :now
      @output.info Time.now.strftime('%Y/%m/%d %H:%M:%S.%L')
    when :autocommit
      if params.nil?
        @output.info "Current autocommit: #{@rdbms.autocommit ? 'on' : 'off'}"
      elsif %[on off].include?(params.downcase)
        @rdbms.autocommit = params.downcase == 'on'
        @output.info "Turning autocommit #{params.downcase}"
      else
        @output.error "Invalid option: '#{params}'. Required: [on|off]"
      end
    else
      # TODO
      @output.error "Unknown command. Possibly a bug."
    end
  end

  def quit!
    @rdbms.close rescue nil
    exit 0
  end

end#Controller
end#JRubySQL
