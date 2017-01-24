# StateInspector
[![Gem Version](https://badge.fury.io/rb/state_inspector.svg)](http://badge.fury.io/rb/state_inspector)
[![Build Status](https://travis-ci.org/danielpclark/state_inspector.svg?branch=master)](https://travis-ci.org/danielpclark/state_inspector)
[![SayThanks.io](https://img.shields.io/badge/SayThanks.io-%E2%98%BC-1EAEDB.svg)](https://saythanks.io/to/danielpclark)

The original purpose of this project is to log state change on target objects.  This will expand
further into additional introspection as new versions are made available.

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
```

Now everytime the setter method is used for `thing` a new line will be entered into a log file
of the object, method, old value, and new value.  So you will see what is changed from where in
the order that the changed occurred.  This session logger will grab as many objects state changes
as you want and give you a nice ordered history of what has occurred.

If you don't want to inform on all instances of a class then instead of running `toggle_informant`
on the class itself then simply execute that method on the instances you want to observe.

If you want to see the expected results of the current observer/reporters then see [test/reporter_test.rb](https://github.com/danielpclark/state_inspector/blob/master/test/reporter_test.rb).

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

## Manually Create Informers

To manually create informant methods use `state_inspector.snoop_setters :a=, :b=` and
`state_inspector.snoop_methods :a, :b`.  Until 1.0 you may end up doubling reports if
you do this more than once or perform this on an already defined attr setter.

## Road Map

* 0.8.0 State inspection of all flagged objects on setter methods.
Includes logger observer, internal observer, and null observer.

* 0.9.0 Sweep for missed setter methods and prepend inspection behavior.

* 1.0.0 Optional reporting on all/target method calls

**1.0 will be an internal implementation rewrite.**  The code you write will be the same
for this library.  The main difference is instead of sleeper informants being handled by rewriting
attr methods the new implementation will just integrate the behavior into the `toggle_informant`
method.

## Reporter Legend

The format of a report sent will alwats start with the object that sent it; aka `self`.  Next you will
have either a string representing and instance variable of a symbol representing a method call.  If it's
an instance variable then the next value will be the old value for that instance variable, and the next
value is the value given to the method to be set as the value for that instance variable.  If the second
item is a symbol then every item after that is the parameters sent to that method.


---
**LEGEND FOR SETTER**
`self, @instance_variable, :old_value, :new_value_given`
---
**LEGEND FOR METHOD**
`self, :method_name, :arguments`
---

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/danielpclark/state_inspector.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

