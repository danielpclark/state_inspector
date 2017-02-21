require 'state_inspector'
require 'state_inspector/observers'
module StateInspector
  module Helper
    def self.included(base)
      base.include Observers
    end

    def toggle_snoop(obj, observer=nil)
      if observer
        old_observer = Reporter.has_observer?(obj) ? Reporter[obj] : nil
        Reporter[obj] = observer
      end
      obj.toggle_informant
      value = yield Reporter[obj]
    ensure
      obj.toggle_informant
      (old_observer.nil? ? Reporter.drop(obj) : Reporter[obj] = old_observer) if observer
      value
    end

    def toggle_snoop_clean(obj, observer=nil)
      obj.state_inspector.skip_setter_snoops
      if observer
        old_observer = Reporter.has_observer?(obj) ? Reporter[obj] : nil
        Reporter[obj] = observer
      end
      obj.toggle_informant
      value = yield Reporter[obj]
    ensure
      obj.toggle_informant
      si = obj.respond_to?(:class_exec) ? obj : obj.class
      obj.state_inspector.restore_methods(*si.instance_variable_get(:@state_inspector).keys)
      si.remove_instance_variable(:@state_inspector) 
      (old_observer.nil? ? Reporter.drop(obj) : Reporter[obj] = old_observer) if observer
      value
    end
  end
end
