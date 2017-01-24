require 'read_source'

module StateInspector
  class StateInspector
    def initialize base, **opts
      @base = base # pass in self

      ## setter_filter # Choose whether to enforce setters ending with equals
      @setter_filter = opts.fetch(:setter_filter) { false }
    end

    def snoop_setters *setters
      base.class_exec do
        setters.map(&:to_sym).
          select {|m| @setter_filter ? m.to_s =~ /=\z/ : m }.
          select {|m| ![:attr_writer, :attr_accessor].include?(instance_method(m).attr?) }.
          each do |m|
            original_method = instance_method(m)
            define_method(m) do |*args, &block|
              var = "@#{__method__.to_s.chop}"
              tell_si var, instance_variable_get(var), *args, &block
              original_method.bind(self).call(*args, &block)
            end
          end
      end
    end

    def snoop_methods *meth0ds
      base.class_exec do
        meth0ds.map(&:to_sym).
          each do |m|
            original_method = instance_method(m)
            define_method(m) do |*args, &block|
              tell_si __method__, *args, &block
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
