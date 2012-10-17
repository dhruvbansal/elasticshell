root = File.expand_path('../', __FILE__)

lib  = File.join(root, 'lib')
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name         = 'elasticshell'
  s.version      = File.read(File.join(root, 'VERSION')).strip
  s.platform     = Gem::Platform::RUBY
  s.authors      = ['Dhruv Bansal']
  s.email        = ['dhruv@infochimps.com']
  s.homepage     = 'http://github.com/dhruvbansal/elasticshell'
  s.summary      = "A command-line shell for Elasticsearch"
  s.description  =  "Elasticshell provides a command-line shell 'es' for connecting to and querying an Elasticsearch database.  The shell will tab-complete Elasticsearch API commands and index/mapping names."
  s.files        = Dir["{bin,lib,spec}/**/*"] + %w[LICENSE README.rdoc VERSION]
  s.executables  = ['es']
  s.require_path = 'lib'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'ZenTest'
  
  s.add_dependency 'json'
  s.add_dependency 'configliere'
  s.add_dependency 'rubberband'
  s.add_dependency 'ripl'
end
