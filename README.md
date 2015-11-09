# StrictStates

Provides utility lookup methods to be used to access the states of your state machine to ensure you never typo them.
Will raise errors on state machine state typos immediately, so if the code runs you know it is correct.

Expected to be compatible with, and support multiple state machines per model, for:

* The venerable [state_machine](https://github.com/pluginaweek/state_machine) gem (Rails 3 max)
* The [@seuros](https://github.com/seuros) forked [state_machine](https://github.com/seuros/state_machine) repo (Rails 4 compat!)
* The community-driven rewrite [state_machines](https://github.com/state-machines/state_machines) gem (Rails 4 & 5 compat!)
* The venerable [aasm](https://github.com/aasm/aasm) gem (formerly "acts_as_state_machine") (Rails 3 & 4)
  * Both pre and post version 4.3.0 when multiple state machines per model was added.

Please file a bug if compatibility is missing for your state machine.

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

# strict_state

Given a state return the same state if they are valid for the given state machine,
otherwise raise an error

Example:

```ruby
MyModel.strict_state(:good, machine_name: :state)
=> "good"
MyModel.strict_state(:not_actually_a_thing, machine_name: :drive_status) # Can support multiple state machines per model
=> KeyError: key not found: :not_actually_a_thing
```

This is better than creating discrete constants for each potential state string in a state machine,
because this checks, at app boot, to ensure the states are correct.
(e.g. "gift card", vs "gift_card").
      
# strict_state_array

Given an array of states return the same array of states if they are valid for the given state machine,
otherwise raise an error

Example:

```ruby
MyModel.strict_state_array(:good, :bad, :on_hold, machine_name: :state)
=> ["good", "bad", "on_hold"]
MyModel.strict_state(:good, :bad, :steve_martin, machine_name: :drive_status) # Can support multiple state machines per model
=> KeyError: key not found: :steve_martin
```

This is better than creating discrete constants for each potential set of states in a state machine,
because this checks, at app boot, to ensure the states are correct.
Raw strings in scopes and queries, not created via this method,
will not be bound to the state machine's implementation, so they will fail silently.
e.g. typos like "gift card" vs "gift_card" and no error raised


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/strict_states. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

