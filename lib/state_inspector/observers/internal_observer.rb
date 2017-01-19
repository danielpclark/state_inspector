require_relative 'observer'

module StateInspector
  module Observers
    module InternalObserver
      class << self
        include Observer
        def purge
          @values = []
        end
      end
    end
  end
end
