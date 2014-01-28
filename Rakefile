$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))

require 'rspec/core/rake_task'

require 'net/nntp/version'

task :default => [:spec]

task :spec do
  RSpec::Core::RakeTask.new do |task|
    task.verbose = false
    task.rspec_opts = '--color'
  end
end

task :test => :spec do
end

task :build do
  system 'gem build net-nntp.gemspec'
end

task :release => :build do
  system "gem push net-nntp-#{Net::NNTP::VERSION}.gem"
end

task :clean do
  system 'rm -f *.gem'
end
