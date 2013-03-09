require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = '--color '
  task.rspec_opts << '--format documentation '
end

task :default => :spec

desc "Generate Lexer"
task :lexer do
  `rex sess_pool_language.rex -o sess_pool_scanner.rb`
end
