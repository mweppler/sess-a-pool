require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

desc "Generate Lexer"
task :lexer do
  `rex sess_pool_language.rex -o sess_pool_scanner.rb`
end
