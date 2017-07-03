module BrokenRecord
  module Patches
    module ErrorTracker
      BUILT_IN_VALIDATION_METHOD = 'validate_each'

      def add(attribute, message = :invalid, options = {})
        # Track the source location
        @error_mapping ||= {}
        _message = normalize_message(attribute, message, options)
        caller_location = caller_locations(1,1)[0]
        calling_method = caller_location.base_label

        if calling_method == BUILT_IN_VALIDATION_METHOD
          validator = @base._validators[attribute].find do |validator|
            caller.any? { |trace| trace.include? validator.validator_source_path }
          end

          validator_caller_location = validator&.allocation_caller_locations&.find { |location| location.to_s =~ Regexp.new(Rails.root.to_s) }

          # if we cannot location exact validator, we are using normal backtrace
          caller_location = validator_caller_location || caller_location

          @error_mapping[_message] = {
            context:  _message,
            source: "#{caller_location.path}:#{caller_location.lineno}"
          }
        else

          @error_mapping[_message] = {
            context: "##{calling_method}",
            source: "#{caller_location.path}:#{caller_location.lineno}"
          }
        end

        super(attribute, message, options)
      end

      def error_mappings
        values.flatten.map { |error_message| [error_message, @error_mapping[error_message]] }
      end
    end
  end
end

ActiveModel::Errors.send(:prepend, BrokenRecord::Patches::ErrorTracker)
