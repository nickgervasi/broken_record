module BrokenRecord
  module Config
    extend self
    attr_accessor :classes_to_skip, :before_scan_callbacks, :after_fork_callbacks, :default_scopes
    self.before_scan_callbacks = []
    self.after_fork_callbacks = []
    self.default_scopes = {}

    def before_scan(&block)
      self.before_scan_callbacks << block
    end

    def after_fork(&block)
      self.after_fork_callbacks << block
    end
  end
end