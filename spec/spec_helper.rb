require 'rspec'

ELASTICSHELL_ROOT = File.expand_path(__FILE__, '../../lib')
$: << ELASTICSHELL_ROOT unless $:.include?(ELASTICSHELL_ROOT)
require 'elasticshell'
include Elasticshell

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |path| require path }

RSpec.configure do |config|
  config.mock_with :rspec
end
