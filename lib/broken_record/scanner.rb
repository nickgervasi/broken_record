require "broken_record/logger"
require 'parallel'

module BrokenRecord
  class Scanner
    def run(model_name = nil)
      models = models_to_validate(model_name)

      BrokenRecord::Config.before_scan_callbacks.each { |callback| callback.call }

      BrokenRecord::Logger.parallel do |lock|
        Parallel.map(models) do |model|
          result = validate_model(model)
          BrokenRecord::Logger.report_output(result, lock)
          result
        end
      end
    end

    private

    def models_to_validate(model_name)
      if model_name
        [ model_name.constantize ]
      else
        load_all_active_record_classes
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

    def validate_model(model)
      ActiveRecord::Base.connection.reconnect!

      BrokenRecord::Logger.log(model) do |logger|
        begin
          default_scope = BrokenRecord::Config.default_scopes[model] || BrokenRecord::Config.default_scopes[model.to_s]

          if default_scope
            model_scope = model.instance_exec &default_scope
          else
            model_scope = model.unscoped
          end

          model_scope.find_each do |r|
            begin
              if !r.valid?
                message = "    Invalid record in #{model} id=#{r.id}."
                r.errors.each { |attr,msg| message <<  "\n        #{attr} - #{msg}" }
                logger.log_error message
              end
            rescue Exception => msg
               message = "    Exception for record in #{model} id=#{r.id} - #{msg}.\n"
               message << caller[0..9].map { |line| "        #{line}"}.join("\n")
               logger.log_error message
            end
          end
        rescue Exception => msg
          logger.log_error "    Error querying model #{model} - #{msg}."
        end
      end
    end
  end
end
