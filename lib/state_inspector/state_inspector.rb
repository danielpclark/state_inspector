module StateInspector
  class StateInspector
    def initialize base, **opts
      @base = base # pass in self
    end

    def snoop_setters *setters
      base.class_exec do
        setters.
          delete_if {|m| (@state_inspector || {}).fetch(m){ nil } }.
          each do |m|
            single = singleton_methods.include?(m) && method(m).owner == self.singleton_class
            original_method = (single ? singleton_method(m).unbind : instance_method(m))
            (@state_inspector ||= {})[m] = {
              contructor: __method__,
              class: self,
              singleton_method: single,
              original_method: original_method
            }
            send((single ? :define_singleton_method : :define_method), m) do |*args, &block|
              var = "@#{__method__.to_s.chop}"
              tell_si var, instance_variable_get(var), *args, &block
              original_method.bind(self).call(*args, &block)
            end
          end
      end
    end

    def snoop_methods *meth0ds
      base.class_exec do
        meth0ds.
          delete_if {|m| (@state_inspector || {}).fetch(m){ nil } }.
          each do |m|
            single = singleton_methods.include?(m) && method(m).owner == self.singleton_class 
            original_method = (single ? singleton_method(m).unbind : instance_method(m))
            (@state_inspector ||= {})[m] = {
              contructor: __method__,
              class: self,
              singleton_method: single,
              original_method: original_method
            }
            send((single ? :define_singleton_method : :define_method), m) do |*args, &block|
              tell_si __method__, *args, &block
              original_method.bind(self).call(*args, &block)
            end
          end
      end
    end

    def restore_methods *meth0ds
      base.class_exec do
        meth0ds.
          select {|m| (@state_inspector || {}).has_key? m }.
          select {|m| self == @state_inspector[m][:class] }.
          each do |m|
            definer = @state_inspector[m][:singleton_method] ? :define_singleton_method : :define_method
            meth0d = send(definer, m, @state_inspector[m][:original_method])
            @state_inspector.delete(m)
            meth0d
          end
      end
    end

    def skip_setter_snoops
      base.instance_variable_set(:@state_inspector, Hash.new) unless base.
        instance_variable_defined? :@state_inspector
    end

    private
    def base
      if @base.respond_to? :class_exec
        @base
      else
        @base.class
      end
    end
  end
end
