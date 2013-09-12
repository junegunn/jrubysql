require 'quote_unquote'

module JRubySQL
class Controller
  include JRubySQL::Messages

  attr_reader :db_type

  def initialize options, argv_str
    @config = JRubySQL::Config.new
    upgrade_jrubysqlrc!

    histories = @config['connections']

    if options.nil?
      if histories.nil? || histories.empty?
        JRubySQL::OptionParser.parse []
      else
        # FIXME: Output
        puts m(:choose_parameter)
        histories.each_with_index do |entry, idx|
          puts "[#{idx + 1}] #{entry.keys.first}"
        end
        print '> '
        select = JRubySQL::Controller.get_console_input
        select = select && select.chomp
        if (1..(histories.length)).include?(select.to_i)
          entry     = histories[select.to_i - 1]
          @options  = entry.values.first[:options]
          @argv_str = entry.keys.first
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
      @input = JRubySQL::Input::Script.new(self, ::File.read(@options[:filename]))
    elsif @options[:script]
      @input = JRubySQL::Input::Script.new(self, @options[:script])
    else
      @input = JRubySQL::Input::Console.new(self)
    end

    # Setting up output: Colored terminal 
    case @options[:output]
    when 'cterm'
      @output = JRubySQL::Output::CTerm.new @config['colors']
      @config['colors'] = @output.colors
    when 'term'
      @output = JRubySQL::Output::Term.new
    when 'csv'
      @output = JRubySQL::Output::CSV.new
    end
  end

  def start
    @output.welcome!
    @output.info m(:connecting)
    begin
      @rdbms = JRubySQL::RDBMS.new @options
    rescue Exception => e
      @output.error e.to_s
      exit 1
    end
    @output.info m(:connected)

    history   = @config['connections'] || []
    entry_idx = history.index { |h| h.keys.first == @argv_str }
    entry     = entry_idx ? history.delete_at(entry_idx) : { @argv_str => {} }
    entry[@argv_str][:options] = @options
    commands = entry[@argv_str][:commands] ||= []
    @input.prepare commands

    history.unshift entry
    history.pop while history.length > JRubySQL::Constants::MAX_CONNECTION_HISTORY
    @config['connections'] = history

    add_cmd = lambda do |c|
      commands.push c unless commands.last == c
      commands.shift while commands.length > JRubySQL::Constants::MAX_COMMAND_HISTORY
      @config['connections'] = history
    end

    loop do
      ret = @input.get

      ret[:sqls].each do |sql|
        begin
          add_cmd.call sql + ret[:delimiter] if ret[:history]
          output @rdbms.execute(sql)
        rescue Exception => e
          @output.error e.to_s
        end
      end if ret.has_key?(:sqls)

      if ret.has_key?(:commands) && ret[:commands].first
        command, line = ret[:commands]
        add_cmd.call line unless command.keys.first == :quit
        process_command command.keys.first, command.values.first
      end
    end
  end

  def cursor empty = true
    @output.cursor empty
  end

  def print_cursor empty = true
    @output.print_cursor empty
  end

private
  def self.get_console_input
    $stdin.gets
  end

  def upgrade_jrubysqlrc!
    history = @config['connections'] || []

    # Convert (0.1.5)
    if !history.empty? && history[0].is_a?(Array)
      history = history.map { |h|
        { h.first => {:options => h.last} }
      }
      @config['connections'] = history
      puts m(:converting_jrubysqlrc)
    end
  end

  def output result
    @output.print_result result
  end

  def process_command cmd, params
    case cmd
    when :help
      @output.print_help
    when :quit
      @output.info m(:goodbye)
      quit!
    when :delimiter
      @output.info m(:set_delimiter, params)
      @input.delimiter = params
    when :now
      @output.info Time.now.strftime('%Y/%m/%d %H:%M:%S.%L')
    when :autocommit
      if params.nil?
        @output.info m(:current_autocommit, @rdbms.autocommit ? 'on' : 'off')
      elsif %w[on off].include?(params.downcase)
        @rdbms.autocommit = params.downcase == 'on'
        @output.info m(:turn_autocommit, params.downcase)
      else
        @output.error m(:invalid_autocommit, params)
      end
    when :display
      params = params.downcase
      if %w[table pairs].include? params
        if @output.respond_to?(:display_mode=)
          @output.display_mode = params.to_sym
        end
      else
        @output.error m(:invalid_display)
      end
    else
      # TODO
      @output.error m(:unknown_command)
    end
  end

  def quit!
    @rdbms.close rescue nil
    exit 0
  end

end#Controller
end#JRubySQL
