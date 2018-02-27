module BrokenRecord
  module Services
    class ClassFinder
      def initialize(class_names)
        @class_names = class_names
      end

      def classes_to_validate
        if @class_names.empty?
          load_all_active_record_classes
        else
          @class_names.map(&:strip).map(&:constantize)
        end
      end

      private

      def load_all_active_record_classes
        Rails.application.eager_load!
        objects = Set.new
        # Classes to skip may either be constants or strings.
        # Convert all to strings for easier lookup
        classes_to_skip = BrokenRecord::Config.classes_to_skip.map(&:to_s)

        ActiveRecord::Base.descendants.each do |klass|
          next if classes_to_skip.include?(klass.to_s)

          # Skip abstract classes since they do not have
          # any records we can validate.
          next if klass.abstract_class?

          # Use base_class so we don't validate STI classes multiple times.
          # See active_record/inheritance.rb for more details.
          objects.add klass.base_class
        end

        prioritized_classes = BrokenRecord::Config.prioritized_models
          .map { |klass| klass.is_a?(Class) ? Class : klass.constantize }
          .select { |klass| objects.delete?(klass) }
        prioritized_classes + objects.sort_by(&:name)
      end
    end
  end
end
