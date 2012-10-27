require 'rubygems'
require 'json'
require 'configliere'

require 'elasticshell/utils'

module Elasticshell

  autoload :Client,   'elasticshell/client'
  autoload :Shell,    'elasticshell/shell'
  autoload :Scope,    'elasticshell/scopes'
  autoload :Scopes,   'elasticshell/scopes'
  autoload :Command,  'elasticshell/command'
  autoload :Commands, 'elasticshell/command'

  def self.version
    @version ||= begin
      File.read(File.expand_path('../../VERSION', __FILE__)).chomp
    rescue => e
      'unknown'
    end
  end
  
end
