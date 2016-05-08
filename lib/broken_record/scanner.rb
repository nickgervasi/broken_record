require 'broken_record/job'
require 'broken_record/job_scheduler'
require 'broken_record/parallel_job_scheduler'
require 'broken_record/external_job_scheduler'
require 'broken_record/result_aggregator'

module BrokenRecord
  class Scanner
    def run(class_names)
      BrokenRecord::Config.aggregator_class.constantize.new.tap do |aggregator|
        classes = classes_to_validate(class_names)

        BrokenRecord::Config.before_scan_callbacks.each { |callback| callback.call }

        scheduler_class = BrokenRecord::Config.job_scheduler_class.constantize
        raise "Invalid job scheduler" unless scheduler_class.ancestors.include?(BrokenRecord::JobScheduler)
        scheduler = scheduler_class.new(classes, aggregator, BrokenRecord::Config.job_scheduler_options)
        scheduler.run
      end
    end

    private

    def classes_to_validate(class_names)
      if class_names.empty?
        load_all_active_record_classes
      else
        class_names.map(&:strip).map(&:constantize)
      end
    end

    def load_all_active_record_classes
      Rails.application.eager_load!
      objects = Set.new
      # Classes to skip may either be constants or strings.  Convert all to strings for easier lookup
      classes_to_skip = BrokenRecord::Config.classes_to_skip.map(&:to_s)
      ActiveRecord::Base.descendants.each do |klass|
        # Use base_class so we don't try to validate abstract classes and so we don't validate
        # STI classes multiple times.  See active_record/inheritance.rb for more details.
        objects.add klass.base_class unless classes_to_skip.include?(klass.to_s)
      end

      objects.sort_by(&:name)
    end
  end
end
