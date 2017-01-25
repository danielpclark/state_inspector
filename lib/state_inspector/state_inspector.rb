module StateInspector
  class StateInspector
    def initialize base, **opts
      @base = base # pass in self
    end

    def snoop_setters *setters
      base.class_exec do
        setters.
          delete_if {|m| (@state_inspector ||= {}).fetch(m){ nil } }.
          each do |m|
            (@state_inspector ||= {})[m] = __method__
            single = singleton_methods.include? m
            original_method = (single ? singleton_method(m) : instance_method(m))
            send((single ? :define_singleton_method : :define_method), m) do |*args, &block|
              var = "@#{__method__.to_s.chop}"
              tell_si var, instance_variable_get(var), *args, &block
              original_method = (single ? original_method.unbind : original_method)
              original_method.bind(self).call(*args, &block)
            end
          end
      end
    end

    def snoop_methods *meth0ds
      base.class_exec do
        meth0ds.
          delete_if {|m| (@state_inspector ||= {}).fetch(m){ nil } }.
          each do |m|
            (@state_inspector ||= {})[m] = __method__
            single = singleton_methods.include? m
            original_method = (single ? singleton_method(m) : instance_method(m))
            send((single ? :define_singleton_method : :define_method), m) do |*args, &block|
              tell_si __method__, *args, &block
              original_method = (single ? original_method.unbind : original_method)
              original_method.bind(self).call(*args, &block)
            end
          end
      end
    end

    private
    def base
      if @base.respond_to? :class_eval
        @base
      else
        @base.class
      end
    end
  end
end
