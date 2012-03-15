require 'yaml'
require 'fileutils'

module JRubySQL
  # A simple key-value config in YAML
  class Config
    DEFAULT_PATH = File.join(ENV['HOME'], '.jrubysqlrc')

    def initialize path = DEFAULT_PATH
      @path = path
      if @path && File.exists?(@path)
        @yaml = YAML.load(File.read(@path))
      end
      @yaml = @yaml || {}
    end

    def [] key
      @yaml[key]
    end

    def []= key, value
      (@yaml[key] = value).tap { dump }
    end

  private
    def dump
      # Try to write atomically 
      File.open(@path + '.tmp', 'w') do |f|
        f << YAML.dump(@yaml)
      end
      FileUtils.mv(@path + '.tmp', @path)
    end
  end#Config
end#JRubySQL

