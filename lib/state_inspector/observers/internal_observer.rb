require_relative 'observer'

module StateInspector
  module Observers
    module InternalObserver
      class << self
        include Observer

        def new
          InternalObserverInstance.new
        end
      end

      class InternalObserverInstance
        include Observer
      end
    end
  end
end
