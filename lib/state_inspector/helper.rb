module StateInspector
  module Helper
    def toggle_snoop(obj)
      obj.toggle_informant
      yield
    ensure
      obj.toggle_informant
    end

    def toggle_snoop_clean(obj)
      obj.state_inspector.skip_setter_snoops
      obj.toggle_informant
      yield
    ensure
      obj.toggle_informant
      obj.instance_exec {@state_inspector = nil} if obj.
        instance_variable_get(:@state_inspector).
        tap {|h| h.is_a?(Hash) ? h.empty? : h}
    end
  end
end
