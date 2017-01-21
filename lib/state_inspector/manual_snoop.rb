
module StateInspector
  class ManualSnoop
    def initialize base
      @base = base # pass in self
    end

    def snoop_setters *setters
      @base.class_eval do
        setters.
          select {|m| m =~ /=\z/}.
          each do |m|
            unless methods_defined_by_attrs.include? m
              original_method = instance_method(m)
              define_method(m) do |value, *args|

                var = "@#{__method__.to_s.chop}"
                tell_si var, instance_variable_get(var), value 

                original_method.bind(self).call(value, *args)
              end
            end
          end
      end
    end

    def snoop_methods *meth0ds
      # TODO
    end

    private

    def methods_defined_by_attrs
      # TODO
    end
  end
end
