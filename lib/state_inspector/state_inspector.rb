module StateInspector
  class StateInspector
    def report who, what, old, new
      Reporter[who].update what, old, new
    end
  end
end
