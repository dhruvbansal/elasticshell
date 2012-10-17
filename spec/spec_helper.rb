require 'rspec'

ELASTICSHELL_ROOT = File.expand_path(__FILE__, '../../lib') unless defined?(ELASTICSHELL_ROOT)
$: << ELASTICSHELL_ROOT unless $:.include?(ELASTICSHELL_ROOT)
require 'elasticshell'
Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |path| require path }
include Elasticshell
include Elasticshell::Spec



