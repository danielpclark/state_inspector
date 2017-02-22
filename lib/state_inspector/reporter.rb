require_relative 'observers/null_observer'

module StateInspector
  # OBSERVABLE PATTERN
  # HASH-LIKE KEY OF OJECT TO OBSERVER/LOGGER INSTANCE
  module Reporter
    class << self
      def [](key)
        reporters[key]
      end

      def []=(key, value)
        reporters[key] = value
      end

      def key? key
        reporters.key?(key)
      end

      def has_observer? key
        reporters.key?(key) || (reporters.key?(key.class) if key.respond_to?(:class_exec))
      end

      def get key
        unless key.respond_to?(:class_exec)
          unless reporters.key?(key)
            return self[key.class]
          end
        end
        self[key]
      end

      def drop key
        reporters.delete key
      end

      def default observer=nil
        @default = observer if observer
        reporters.default = @default
        @default
      end

      private
      def reporters
        @reporters ||= Hash.new.tap do |h|
          h.default = @default || Observers::NullObserver
        end
      end
    end
  end
end
