module BrokenRecord
  module Config
    extend self
    attr_accessor :classes_to_skip, :before_scan_callbacks

    def before_scan(&block)
      self.before_scan_callbacks ||= []
      self.before_scan_callbacks << block
    end
  end
end