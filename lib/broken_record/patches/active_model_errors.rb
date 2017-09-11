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

      # This produces a list of error message, error mapping pairs.
      # ActiveRecord, in some cases, will automatically try to validate associated models when you call valid on
      # the base model.  As such, the actual `error_mapping` instance variable will be on the associated model.
      # It will create an error key that looks like `base.associated_model`, so we find the associated model that way
      # to get the error mapping instance variable and create the full error_mappings pair list.
      def error_mappings
        error_pairs = []
        each do |key, mapping_key|
          delineated_keys = key.to_s.split('.')

          mapping = @error_mapping
          error_message = mapping_key.dup
          if (delineated_keys.length > 1)
            parent = delineated_keys.first
            associated_model = @base.send(parent)
            mapping = associated_model.errors.instance_variable_get(:@error_mapping)
            error_message = "#{associated_model.class} (#{associated_model.id}): #{error_message}"
          end

          error_pairs << [error_message, mapping[mapping_key]]
        end

        error_pairs
      end
    end
  end
end

ActiveModel::Errors.send(:prepend, BrokenRecord::Patches::ErrorTracker) if defined? ActiveModel
