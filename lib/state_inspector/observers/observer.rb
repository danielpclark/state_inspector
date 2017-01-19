module StateInspector
  module Observers
    module Observer
      def update *vals
        values() << vals
      end

      def display
        values.join " "
      end

      def values
        @values ||= []
      end

      def purge
        @values = []
      end
    end
  end
end
