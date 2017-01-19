module StateInspector
  class StateInspector
    def self.report who, what, old, new
      key = who.respond_to?(:class_eval) ? who : who.class
      Reporter[key].update who, what, old, new
    end
  end
end
