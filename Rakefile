require 'bundler'
Bundler.require(:test)
require 'yaml'
require 'rubberband'

desc "Build elasticshell"
task :build do
  system "gem build elasticshell.gemspec"
end

version = File.read(File.expand_path('../VERSION', __FILE__)).strip
desc "Release elasticshell-#{version}"
task :release => :build do
  system "gem push elasticshell-#{version}.gem"
end

namespace :spec do

  def client
    @client ||= ElasticSearch.new("http://localhost:9200")
  end

  namespace :data do

    def data
      @data ||= YAML.load_file(File.join(File.dirname(__FILE__), 'spec/support/data.yml'))
    end

    desc "Empty data from local Elasticsearch database"
    task :delete do
      data.each_pair do |index_name, types|
        client.delete_index(index_name)
      end
    end

    desc "Load data into a local Elasticsearch"
    task :load do
      data.each_pair do |index_name, types|
        types.each_pair do |type_name, records|
          records.each_pair do |id, record|
            if id == '_noid_'
              record.each do |unsaved_record|
                client.index(unsaved_record, :type => type_name, :index => index_name)
              end
            else
              client.index(record, :id => id, :type => type_name, :index => index_name)
            end
          end
        end
      end
    end
  end
end
