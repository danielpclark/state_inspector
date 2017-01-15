require_relative 'null_observer'

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

      private
      def reporters
        @reporters ||= Hash.new.tap {|h|
          h.default = NullObserver
        }
      end
    end
  end
end
