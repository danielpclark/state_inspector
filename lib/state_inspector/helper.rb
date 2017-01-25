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
      (obj.respond_to?(:class_eval) ? obj : obj.class).
        remove_instance_variable(:@state_inspector) 
    end
  end
end
