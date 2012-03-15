require 'quote_unquote'

module JRubySQL
class Controller
  include JRubySQL::Messages

  attr_reader :db_type

  def initialize options, argv_str
    @config = JRubySQL::Config.new
    histories = @config['connections']

    if options.nil?
      if histories.nil? || histories.empty?
        JRubySQL::OptionParser.parse []
      else
        # FIXME: Output
        puts m(:choose_parameter)
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
    case @options[:output]
    when 'cterm'
      @output = JRubySQL::Output::CTerm.new
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

    history = @config['connections'] || []
    history.unshift [@argv_str, @options]
    history.uniq!
    if history.length > JRubySQL::Constants::MAX_CONNECTION_HISTORY
      history = history[0, JRubySQL::Constants::MAX_CONNECTION_HISTORY]
    end
    @config['connections'] = history

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
      elsif %[on off].include?(params.downcase)
        @rdbms.autocommit = params.downcase == 'on'
        @output.info m(:turn_autocommit, params.downcase)
      else
        @output.error m(:invalid_autocommit, params)
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
