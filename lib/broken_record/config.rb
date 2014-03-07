module BrokenRecord
  module Config
    extend self
    attr_accessor :classes_to_skip, :before_scan_callbacks, :default_scopes, :show_duration
    self.before_scan_callbacks = []
    self.default_scopes = {}
    self.show_duration = false

    def before_scan(&block)
      self.before_scan_callbacks << block
    end
  end
end