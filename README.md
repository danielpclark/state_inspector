<img src="https://s23.postimg.org/vhe8ke1ff/observer_hooks2.png" alt="Observer Hooks" align="right" width="50" height="44" />
# StateInspector
[![Gem Version](https://badge.fury.io/rb/state_inspector.svg)](http://badge.fury.io/rb/state_inspector)
[![Build Status](https://travis-ci.org/danielpclark/state_inspector.svg?branch=master)](https://travis-ci.org/danielpclark/state_inspector)
[![SayThanks.io](https://img.shields.io/badge/SayThanks.io-%E2%98%BC-1EAEDB.svg)](https://saythanks.io/to/danielpclark)

This can fully inform on object method calls and parameters as well as instance variables before and after (when called via a setter method).  In short this utilizes the decorator patttern and the observer pattern to hook and report when a method is called.  In simple terms it will wrap any methods you choose with a hook that sends off all the details of the method call when it is executed to a reporter/observer of your choosing.

This project uses a variation of the observer pattern.  There is a hash of Reporters where you can
mark the key as a class instance or the class itself and point it to an Observer object.  Three
observers are included for you to use under StateInspector::Observers which are NullObserver (default),
InternalObserver, and SessionLoggerObserver.  When you toggle on an "informant" on a class instance or
class then each time a setter method is called it will pass that information on to the relevant observer
which handles the behavior you want to occur with that information.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'state_inspector'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install state_inspector

## Usage

The preferred usage is to pick what classes you want to track state change in and have them logged to
a session logger.  To do this you would need to do the following.

```ruby
require 'state_inspector'
require 'state_inspector/observers/session_logger_observer'
include StateInspector::Observers

class MyClass
  attr_writer :thing
end

StateInspector::Reporter[MyClass] = SessionLoggerObserver

MyClass.toggle_informant

m = MyClass.new
m.thing = :a

StateInspector::Reporter[MyClass].values
# => [["#<MyClass:0x005571fde5e498>", "@thing", nil, :a]]
```
SessionLoggerObserver will by default log reports to `log/state_inspector/`.

Now everytime the setter method is used for `thing` a new line will be entered into a log file
of the object, method, old value, and new value.  So you will see what is changed from where in
the order that the changed occurred.  This session logger will grab as many objects state changes
as you want and give you a nice ordered history of what has occurred.

If you don't want to inform on all instances of a class then instead of running `toggle_informant`
on the class itself then simply execute that method on the instances you want to observe.

If you want to see the expected results of the current observer/reporters then see [test/reporter_test.rb](https://github.com/danielpclark/state_inspector/blob/master/test/reporter_test.rb).

If you want to only toggle an informant for a small area you may use a helper method to toggle the
observer on and off for you.

```ruby
require 'state_inspector/helper'
include Helper

# instead of doing MyClass.toggle_informant as above, do this.

m = MyClass.new
toggle_snoop(m) do
  # put your own code here
end
```

When writing tests for code and using StateInspector it's very important to ensure the informant is
untoggled.  Otherwise you will have sporatic behavior in your tests.  You may use the helpers provided
here for your tests to ensure you won't have glitchy tests as a result of using informants.

To include it in Minitest you would do:

```ruby
# test/test_helper.rb or test/minitest_helper.rb

require 'state_inspector/helper'
class Minitest::Test
  include StateInspector::Helper
end
```

The default behavior for toggling on an informant for the first time is to inject code to observe all
setter methods.  This is true for both the Object method `toggle_informant` and the helper method
`toggle_snoop`.  If you would like to avoid injecting all setter methods for reporting you may either
use `state_inspector.skip_setter_snoops` (before any toggling) or the helper `toggle_snoop_clean` which
will cleanly remove its anti-setter hook once done (meaning the next `toggle_informant` will inject the
informant code into all setters).


## Observers

To include all Observers into scope you can do:

```ruby
require 'state_inspector/observers'
include StateInspector::Observers
```

You may look at the available observers in [state_inspector/observers](https://github.com/danielpclark/state_inspector/tree/master/lib/state_inspector/observers).

Observers will have a few methods they each have in common.

```ruby
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
```

When you're writing your own observer you'll include this Observer onto a module's instance and
overwrite whatever methods you want there.

```ruby
module ExampleObserver
  class << self
    include Observer
    def display
      "Custom display code here"
    end
  end
end
```

And to register this observer to a target class you simply write:

```ruby
StateInspector::Reporter[MyTargetClass] = ExampleObserver
```

## Manually Create or Remove Informers

To manually create informant methods use `state_inspector.snoop_setters :a=, :b=` and
`state_inspector.snoop_methods :a, :b`.  

```ruby
require 'state_inspector'
require 'state_inspector/observers/internal_observer'
include StateInspector::Observers

class MyClass
  attr_writer :a, :b, :c
  def x *args; end
end

# InternalObserver (it can be used with many classes and hold all of the data)
# InternalObserver.new (will hold data for only the specific reporter object pointing to it)
StateInspector::Reporter[MyClass] = InternalObserver

# This will allow us to manually define which setter methods to inform on
MyClass.state_inspector.skip_setter_snoops

m = MyClass.new
m.toggle_informant
m.state_inspector.snoop_setters :b=, :c=
m.state_inspector.snoop_methods :x
m.a= 1
m.b= 2
m.c= 3
m.x 4, 5, 6

StateInspector::Reporter[MyClass].values
# => [
#      [#<MyClass:0x005608eb9aead0 @informant=true, @a=1, @b=2, @c=3>, "@b", nil, 2],
#      [#<MyClass:0x005608eb9aead0 @informant=true, @a=1, @b=2, @c=3>, "@c", nil, 3],
#      [#<MyClass:0x005608eb9aead0 @informant=true, @a=1, @b=2, @c=3>, :x, 4, 5, 6]
#    ]
```
The nils in the values above represent the previous value the instance variable returned.

#### Remove Informers

To remove informers simply use `state_inspector.restore_methods`.  This takes out the hook from
each method that waits for the `informer?` method to be true.

```ruby
# continuing from the above example

m.state_inspector.restore_methods :b=, :c=, :x
```

## Reporter Legend

The format of a report sent will always start with the object that sent it; aka `self`.  Next you will
have either a string representing and instance variable of a symbol representing a method call.  If it's
an instance variable then the next value will be the old value for that instance variable, and the next
value is the value given to the method to be set as the value for that instance variable.  If the second
item is a symbol then every item after that is the parameters sent to that method.


LEGEND FOR SETTER| _ | _ | _
-----------------|---|---|---
`self` | `@instance_variable` | `:old_value` | `:new_value_given`


LEGEND FOR METHOD| _ | _ 
-----------------|---|---
`self` | `:method_name` | `:arguments`


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/danielpclark/state_inspector.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

