require 'app_indicator_ssh/error'
require 'app_indicator_ssh/config'
require 'rubygems'
require 'log4r'
require 'log4r/outputter/emailoutputter'
include Log4r


class Log
  attr_accessor :level
  def initialize(args={})
    args.each { |key, value| send("#{key}=", value) if respond_to?(key) }
    @config=HostsConfig.new(:filename => 'logging.yml').load_config
    @logger = Logger.new @config['log']['name']
    format = PatternFormatter.new(:pattern => "[%l]\t%d: %m")
    @logger.add FileOutputter.new 'file',
              :filename => File.dirname(__FILE__) + "/../../log/#{@config['log']['log_file']}",
              :formatter => format,
              :trunc => false,
              :level => Log4r::DEBUG
    @logger.add EmailOutputter.new 'emailOut',
              :server=> @config['smtp']['host'],
              :port=> @config['smtp']['port'],
              :domain=> @config['smtp']['domain'],
              :from=> @config['smtp']['from_address'],
              :to=> @config['smtp']['to_address'],
              :immediate_at=>'ERROR',
              :buffsize=> 25

  end

  def write(level, msg)
    cfg_level=@config['log']['log_level']
    if cfg_level != 'quiet'
      @logger.send level, msg
    end
  end


end

