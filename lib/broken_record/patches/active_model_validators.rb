module BrokenRecord
  module Patches
    module ValidatorTracker
      attr_reader :allocation_caller_locations, :validator_source_path

      def initialize(*args)
        @allocation_caller_locations = caller_locations

        @validator_source_path = begin
          self.method(:validate_each).source_location[0]
        rescue
          nil
        end

        super(*args)
      end
    end
  end
end

ActiveModel::Validator.send(:prepend, BrokenRecord::Patches::ValidatorTracker)
