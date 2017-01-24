require_relative 'state_inspector'
require_relative 'reporter'

module StateInspector
  module Snoop
    def Snoop.extended(base)
      base.include ClassMethods
    end

    def attr_writer *attr_names
      attr_names.each do |attr_name|
        define_method("#{attr_name}=") do |value|
          ivar = "@#{attr_name.to_s}"
          tell_si ivar, instance_variable_get(ivar), value 

          instance_variable_set(ivar, value)
        end
      end
      nil
    end

    def attr_accessor *attr_names
      attr_names.each do |attr_name|
        define_method("#{attr_name}") do
          instance_variable_get("@#{attr_name.to_s}")
        end

        self.attr_writer(attr_name)
      end
    end

    module ClassMethods
      def state_inspector
        StateInspector.new(self)
      end

      def tell_si *args, &block
        if informant?
          key = self.respond_to?(:class_eval) ? self : self.class
          Reporter[key].update(self, *args, &block)
        end
      end

      def toggle_informant
        @informant = !@informant
      end

      def informant?
        @informant || self.class.instance_variable_get(:@informant)
      end
    end
  end
end
