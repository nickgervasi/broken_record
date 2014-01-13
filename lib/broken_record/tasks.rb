require 'rake'

namespace :broken_record do
  desc 'Scans all models for validation errors'
  task :scan, [:model_name] => :environment do |t, args|
    scanner = BrokenRecord::Scanner.new
    scanner.run(args[:model_name])
  end
end