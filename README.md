# StrictStates

Provides utility lookup methods to be used to access the states of your state machine to ensure you never typo them.
Will raise errors on state machine state typos immediately, so if the code runs you know it is correct.

| Project                 |  StrictStates    |
|------------------------ | ----------------- |
| gem name                |  strict_states   |
| license                 |  MIT              |
| expert support          |  [![Get help on Codementor](https://cdn.codementor.io/badges/get_help_github.svg)](https://www.codementor.io/peterboling?utm_source=github&utm_medium=button&utm_term=peterboling&utm_campaign=github) |
| download rank               |  [![Total Downloads](https://img.shields.io/gem/rt/strict_states.svg)](https://rubygems.org/gems/strict_states) |
| version                 |  [![Gem Version](https://badge.fury.io/rb/strict_states.png)](http://badge.fury.io/rb/strict_states) |
| dependencies            |  [![Dependency Status](https://gemnasium.com/pboling/strict_states.png)](https://gemnasium.com/pboling/strict_states) |
| code quality            |  [![Code Climate](https://codeclimate.com/github/pboling/strict_states.png)](https://codeclimate.com/github/pboling/strict_states) |
| inline documenation     |  [![Inline docs](http://inch-ci.org/github/pboling/strict_states.png)](http://inch-ci.org/github/pboling/strict_states) |
| continuous integration  |  [![Build Status](https://secure.travis-ci.org/pboling/strict_states.png?branch=master)](https://travis-ci.org/pboling/strict_states) |
| test coverage           |  [![Coverage Status](https://coveralls.io/repos/pboling/strict_states/badge.png)](https://coveralls.io/r/pboling/strict_states) |
| homepage                |  [on Github.com][homepage] |
| documentation           |  [on Rdoc.info][documentation] |
| live chat               |  [![Join the chat at https://gitter.im/pboling/strict_states](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/pboling/strict_states?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) |
| Spread ~♡ⓛⓞⓥⓔ♡~      |  [on Coderbits][coderbits], [on Coderwall][coderwall] |

[semver]: http://semver.org/
[pvc]: http://docs.rubygems.org/read/chapter/16#page74
[railsbling]: http://www.railsbling.com
[peterboling]: http://www.peterboling.com
[coderbits]: https://coderbits.com/pboling
[coderwall]: http://coderwall.com/pboling
[documentation]: http://rdoc.info/github/pboling/strict_states/frames
[homepage]: https://github.com/pboling/strict_states


Expected to be compatible with, and support multiple state machines per model, for:

* The venerable [state_machine](https://github.com/pluginaweek/state_machine) gem (Rails 3 max)
* The [@seuros](https://github.com/seuros) forked [state_machine](https://github.com/seuros/state_machine) repo (Rails 4 compat!)
* The community-driven rewrite [state_machines](https://github.com/state-machines/state_machines) gem (Rails 4 & 5 compat!)
* The venerable [aasm](https://github.com/aasm/aasm) gem (formerly "acts_as_state_machine") (Rails 3 & 4)
  * Both pre and post version 4.3.0 when multiple state machines per model was added.

Please file a bug if compatibility is missing for your state machine.

`:machine_name` as `:state` is so universally common that it has been made the default when not provided.

Most apps only use one state machine implementation, like aasm, or state_machines, however, apps can (and do) use multiple state machine implementations at the same time.  This gem supports that, and keeps all the states per-model, per-machine, per-engine separate!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'strict_states'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install strict_states

## Usage

```ruby
class MyModel < ActiveRecord::Base
  # ...
  # <<<===--- AFTER STATE MACHINE DEFINITION ---===>>>
  # ...
  include StrictStates.checker(
              klass: self,
              machines: {
                  state: :pluginaweek,
                  awesome_level: :pluginaweek,
                  bogus_level: ->(context, machine_name) {
                    context.state_machines[machine_name.to_sym].states.map(&:name)
                  }
              }
          )
end
```

### strict_state

Given a state return the same state if they are valid for the given state machine,
otherwise raise an error

Example:

```ruby
MyModel.strict_state(:good, machine_name: :state)
=> "good"
```

```ruby
MyModel.strict_state(:not_actually_a_thing, machine_name: :drive_status)
=> KeyError: key not found: :not_actually_a_thing
```

This is better than creating discrete constants for each potential state string in a state machine,
because this checks, at app boot, to ensure the states are correct.
(e.g. "gift card", vs "gift_card").
      
### strict_state_array

Given an array of states return the same array of states if they are valid for the given state machine,
otherwise raise an error.

Example:

```ruby
MyModel.strict_state_array(:good, :bad, :on_hold, machine_name: :state)
=> ["good", "bad", "on_hold"]
```

```ruby
MyModel.strict_state_array(:good, :bad, :steve_martin, machine_name: :drive_status)
=> KeyError: key not found: :steve_martin
```

This is better than creating discrete constants for each potential set of states in a state machine,
because this checks, at app boot, to ensure the states are correct.
Raw strings in scopes and queries, not created via this method,
will not be bound to the state machine's implementation, so they will fail silently.
e.g. typos like "gift card" vs "gift_card" and no error raised

### strict_all_state_names

Given the name of a state machine, returns all states defined by the state machine, as an array of strings.

```ruby
MyModel.strict_all_state_names(machine_name: :state)
=> ["good", "bad", "on_hold"]
```

### state_lookup

Given a machine name return the StrictStates::StrictHash used to lookup valid states.

```ruby
MyModel.state_lookup(machine_name: :state)
=> { :new => "new", :pending => "pending", :goofy => "goofy" }
```

### strict_state_lookup

Returns a StrictStates::StrictHash representation of all the state machine state definitions in the class.  A class can have more than one state machine.

```ruby
MyModel.strict_state_lookup
=>  {
      :awesome_level =>
        { :not_awesome => "not_awesome", :awesome_11 => "awesome_11", :bad => "bad", :good => "good" },
      :bogus_level =>
        { :new => "new", :pending => "pending", :goofy => "goofy" }
    }
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/strict_states. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

