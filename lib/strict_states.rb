require "strict_states/version"
require "strict_states/strict_hash"
require "strict_states/checker"

# The *STRICT* paradigm:
#
#   * Will raise an error if states are spelled wrong when lookups happen through this paradigm.
#   * Typos will be noisy, and many of them will error at app-load, so impossible to miss.
#
# Uses the StrictHash to accomplish this.  See lib/strict_states/strict_hash.rb
#
# The *INCLUDE WITH ARGUMENTS* paradigm:
#
#   * future-proof support for any/all state machines
#   * easily integrate with any state machine engine not already supported by this gem
#
# Uses a method (StrictStates.checker) that returns a module (StrictStates::Checker) to accomplish this.
module StrictStates
  # Usage:
  #
  #     class MyModel < ActiveRecord::Base
  #       # ...
  #       # <<<===--- AFTER STATE MACHINE DEFINITION ---===>>>
  #       # ...
  #       include StrictStates.checker(
  #                   klass: self,
  #                   machines: {
  #                       state: :pluginaweek,
  #                       awesome_level: :pluginaweek,
  #                       bogus_level: ->(context, machine_name) {
  #                         context.state_machines[machine_name.to_sym].states.map(&:name)
  #                       }
  #                   }
  #               )
  #     end
  #
  def self.checker(**config)
    validate_config(config)
    config[:machines] = states_for_machines(config[:klass], config[:machines])
    set_strict_state_lookup(config)
    ::StrictStates::Checker
  end

  private

  # Supported engines:
  #
  #   :pluginaweek    - for pluginaweek/state_machine
  #   :seuros         - for seuros/state_machine
  #   :state_machines - for state-machines/state_machines
  #   :aasm           - for aasm/aasm version < 4.3.0
  #   :aasm_multiple  - for aasm/aasm version >= 4.3.0
  #
  def self.engine_name_apis
    {
        pluginaweek:    ->(context, machine_name) { context.state_machines[machine_name.to_sym].states.map(&:name) },
        seuros:         ->(context, machine_name) { context.state_machines[machine_name.to_sym].states.map(&:name) },
        state_machines: ->(context, machine_name) { context.state_machines[machine_name.to_sym].states.map(&:name) },
        aasm:           ->(context, _)            { context.aasm.states.map(&:name) },              # aasm gem version < 4.3.0
        aasm_multiple:  ->(context, machine_name) { context.aasm(machine_name).states.map(&:name) } # aasm gem version >= 4.3.0
    }
  end

  def self.strict_states_to_stings(states)
    states.map {|state| state.to_s }
  end

  def self.create_strict_state_lookup(names)
    default_strict_hash = names.each_with_object({}) do |state, memo|
      memo[state.to_sym] = state
    end
    StrictHash[**default_strict_hash]
  end

  def self.validate_config(**config)
    raise ArgumentError, "config must have a :machines key with Hash value  but was #{config[:machines]}" unless config[:machines] && config[:machines].is_a?(Hash)
    raise ArgumentError, ":machines Hash must have values either from #{engine_name_apis.keys} or as Procs but was #{config[:machines]}" unless test_machines(config[:machines])
    raise ArgumentError, "config must have a :klass key with a Class value but was #{config[:klass]}" unless config[:klass] && config[:klass].class == Class
    true
  end

  def self.test_machines(machines)
    machines.values.all? do |engine|
      engine_name_apis.keys.include?(engine) ||
          engine.respond_to?(:call)
    end
  end

  # params:
  #   klass - any Class object with a state machine
  #   machines -
  #     {
  #         state: :pluginaweek,
  #         awesome_level: :pluginaweek,
  #         bogus_level: ->(context, machine_name) {
  #           context.state_machines[machine_name.to_sym].states.map(&:name)}
  #     }
  #
  # Example result
  #
  #     {
  #         state:          ["one", "two", "three"],
  #         awesome_level:  ["not_awesome", "awesome_11", "bad", "good"],
  #         bogus_level:    ["new", "pending", "goofy"]
  #     }
  #
  def self.states_for_machines(klass, machines)
    machines.inject({}) do |memo, (machine_name, engine)|
      proc = get_proc_for_engine(engine)
      memo[machine_name] =
          strict_states_to_stings(
              proc.call(klass, machine_name)
          )
      memo
    end
  end

  def self.get_proc_for_engine(engine)
    if (proc = engine_name_apis[engine])
      # Predefined Engine within this gem
      proc
    else
      # Custom state machine name extraction Proc provided by caller
      engine
    end
  end

  # params:
  #   config -
  #     {
  #       klass: Car, # any Class object with a state machine
  #       machines: { # the machine names, and states defined within each
  #         state:          ["one", "two", "three"],
  #         awesome_level:  ["not_awesome", "awesome_11", "bad", "good"],
  #         bogus_level:    ["new", "pending", "goofy"]
  #       }
  #     }
  def self.set_strict_state_lookup(config)
    klass = config[:klass]
    machines = config[:machines]
    class << klass
      attr_reader :strict_state_lookup
    end
    klass.instance_variable_set(:@strict_state_lookup, {})
    machines.each do |machine_name, state_array|
      klass.strict_state_lookup[machine_name.to_sym] = StrictStates.create_strict_state_lookup(state_array).freeze
    end
  end

end
