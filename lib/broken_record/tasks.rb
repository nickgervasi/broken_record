require 'rake'

namespace :broken_record do
  desc 'Scans all models for validation errors'
  task :scan, [:model_name] => :environment do |t, args|
    scanner = BrokenRecord::Scanner.new
    results = scanner.run(args[:model_name])
    BrokenRecord::Logger.report_results(results)
  end
end