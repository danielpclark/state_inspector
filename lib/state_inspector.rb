require 'state_inspector/version'
require 'state_inspector/snoop'

module StateInspector
  class ::Object
    extend Snoop
  end
end
