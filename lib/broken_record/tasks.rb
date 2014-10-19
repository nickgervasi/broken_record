require 'rake'

namespace :broken_record do
  desc 'Scans models for validation errors'
  task :scan, [:class_name] => :environment do |t, args|
    scanner = BrokenRecord::Scanner.new
    class_names = args[:class_name] ? [args[:class_name]] : []
    class_names += args.extras
    scanner.run(class_names)
  end
end
