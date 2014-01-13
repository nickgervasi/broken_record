# rake tasks for Rails 3+
module BrokenRecord
  class Railtie < ::Rails::Railtie
    rake_tasks do
      require "broken_record/tasks"
    end
  end
end
