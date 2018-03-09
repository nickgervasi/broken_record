require 'rake'

namespace :broken_record do
  desc 'Scans models for validation errors'
  task :scan, [:class_name] => :environment do |t, args|
    scanner = BrokenRecord::Scanner.new
    class_names = args[:class_name] ? [args[:class_name]] : []
    class_names += args.extras
    aggregator = scanner.run(class_names)
    aggregator.report_final_results

    aggregator.exit_program
  end
end
