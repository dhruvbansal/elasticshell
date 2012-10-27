require 'logger'

module Elasticshell
  
  Settings.define(:log,       :description => "Path to a log file (defaults to STDERR)", :env_var => "ES_LOG", :default => STDERR)
  Settings.define(:log_level, :description => "Log level", :default => "info",            :env_var => "ES_LOG_LEVEL")

  Settings.define(:http_request_format,
                  :description => "Format string for an HTTP request.  The string `%v' will be replaced by the (formatted) verb, `%h' by the host, `%p' by the path.",
                  :default     => "  \e[1m=> %v \e[0m\e[39m%h\e[1m%p\e[0m",
                  :internal    => true)

  Settings.define(:debug_format,
                  :description => "Format string for a a DEBUG log message.  The string `%m' will be replaced by the message",
                  :default     => "\e[1m\e[32mDEBUG:\e[0m %m",
                  :internal    => true)

  Settings.define(:info_format,
                  :description => "Format string for a a INFO log message.  The string `%m' will be replaced by the message",
                  :default     => "\e[1m\e[34mINFO:\e[0m %m",
                  :internal    => true)
  
  Settings.define(:warn_format,
                  :description => "Format string for a a WARN log message.  The string `%m' will be replaced by the message",
                  :default     => "\e[1m\e[35mWARN:\e[0m %m",
                  :internal    => true) 
  
  Settings.define(:error_format,
                  :description => "Format string for a a ERROR log message.  The string `%m' will be replaced by the message",
                  :default     => "\e[1m\e[31mERROR:\e[0m %m",
                  :internal    => true) 
 
  def self.log
    @log ||= default_logger
  end

  def self.default_logger
    Logger.new(Settings[:log]).tap do |l|
      begin
        l.level = Logger::Severity.const_get(Settings[:log_level].to_s.upcase)
      rescue NameError => e
        STDERR.puts "WARN: Log severity must be one of #{Logger::Severity.map(&:to_s).join(', ')}.  Setting severity to \"info\""
        l.level = Logger::Severity::INFO
      end
      l.formatter = proc do |severity, datetime, progname, msg|
        msg + "\n"
      end
    end
  end

  def self.format name, codes, values
    cs = [codes].flatten
    vs = [values].flatten
    raise ArgumentError.new("Must provide the same number of format codes as value strings.") unless cs.length == vs.length
    Settings[name].dup.tap do |s|
      cs.each_with_index do |c, index|
        v = vs[index]
        s.gsub!(c, v)
      end
    end
  end

  def self.request verb, host, path
    log.info(format(:http_request_format, ["%v", "%h", "%p"], [Shell.formatted_verb(verb), host, path]))
  end
  
  def self.debug msg
    log.debug(format(:debug_format, "%m", msg))
  end

  def self.info msg
    log.info(format(:info_format, "%m", msg))
  end
  
  def self.warn msg
    log.warn(format(:warn_format, "%m", msg))
  end
  
  def self.error msg
    log.error(format(:error_format, "%m", msg))
  end
  
end


