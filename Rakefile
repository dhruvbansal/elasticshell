$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

desc "Build elasticshell"
task :build do
  system "gem build elasticshell.gemspec"
end

version = File.read(File.expand_path('../VERSION', __FILE__)).strip
desc "Release elasticshell-#{version}"
task :release => :build do
  system "gem push elasticshell-#{version}.gem"
end
