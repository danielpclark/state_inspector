require_relative 'state_inspector'
require_relative 'reporter'

module StateInspector
  module Snoop
    def Snoop.extended(base)
      base.include ClassMethods
    end

    module ClassMethods
      def state_inspector
        StateInspector.new(self)
      end

      def tell_si *args, &block
        if informant?
          key = self.respond_to?(:class_exec) ? self : self.class
          key = Reporter.has_key?(key) ? key : self
          Reporter[key].update(self, *args, &block)
        end
      end

      def toggle_informant
        state_inspector.snoop_setters(
          *(self.respond_to?(:class_exec) ? self : self.class).
          instance_methods.grep(/=\z/) - Object.methods
        ) unless @state_inspector || self.class.instance_variable_get(:@state_inspector)

        @informant = !@informant
      end

      def informant?
        @informant || self.class.instance_variable_get(:@informant)
      end
    end
  end
end
