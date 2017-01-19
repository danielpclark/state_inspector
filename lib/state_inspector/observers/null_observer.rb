require_relative 'observer'

module StateInspector
  module Observers
    module NullObserver
      class << self
        include Observer
        def update *_; end
      end
    end
  end
end
