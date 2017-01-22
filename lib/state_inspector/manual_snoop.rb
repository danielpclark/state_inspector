
module StateInspector
  class ManualSnoop
    def initialize base, **opts
      @base = base # pass in self

      ## setter_filter # Choose whether to enforce setters ending with equals
      @setter_filter = opts.fetch(:setter_filter) { false }
    end

    def snoop_setters *setters
      @base.class_eval do
        setters.
          select(&setter_filter).
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

    def setters_defined_by_attrs *setters
      # TODO
    end

    def setter_filter
      ->m{@setter_filter ? m =~ /=\z/ : m}
    end
  end
end
