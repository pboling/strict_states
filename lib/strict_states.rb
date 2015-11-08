require "strict_states/version"
require "strict_states/strict_hash"
require "strict_states/utility_methods"
require "strict_states/checker"

# The *STRICT* paradigm:
#
#   Will raise an error if states are spelled wrong when lookups happen through this paradigm.
#   Typos will be noisy, and many of them will error at app-load, so impossible to miss.
#
# Uses the StrictHash to accomplish this.  See lib/strict_states/strict_hash.rb
#
module StrictStates

  # Usage:
  #
  # class MyModel < ActiveRecord::Base
  #   include StrictStates.checker(
  #               namespace: self.name,
  #               machines: [
  #                   { name: :state, engine: :pluginaweek },
  #                   { name: :awesome_level, engine: :pluginaweek },
  #                   { name: :bogus_level, names_lookup: ->(context, machine_name) { context.state_machines[machine_name.to_sym].states} }
  #               ])
  # end
  #
  def self.checker(**config)
    validate_config(config)
    namespace = config.delete(:namespace)
    @strict_states_config ||= {}
    @strict_states_config[namespace] = config[:machines]
    ::StrictStates::Checker
  end

  def self.config
    @strict_states_config
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
    StrictHash[
        pluginaweek:    ->(context, machine_name) { context.state_machines[machine_name.to_sym].states },
        seuros:         ->(context, machine_name) { context.state_machines[machine_name.to_sym].states },
        state_machines: ->(context, machine_name) { context.state_machines[machine_name.to_sym].states },
        aasm:           ->(context, _)            { context.aasm.states },              # aasm gem version < 4.3.0
        aasm_multiple:  ->(context, machine_name) { context.aasm(machine_name).states } # aasm gem version >= 4.3.0
    ]
  end

  def self.state_names_for_engine(engine_name:, context:, machine_name:)
    self.engine_state_names[engine_name].call(context, machine_name)
  end

  def self.strict_state_get_names(states)
    states.map {|state| state.name.to_s }
  end

  def self.create_strict_state_lookup(names)
    default_strict_hash = names.each_with_object({}) do |state, memo|
      memo[state.to_sym] = state.to_s
    end
    StrictHash[**default_strict_hash]
  end

  def self.validate_config(config)
    raise ArgumentError, "options must have a :machines key with an Array value" unless config[:machines] && config[:klass].is_a?(Array)
    raise ArgumentError, "options must have a :klass key with a String value" unless config[:klass] && config[:klass].is_a?(String)
    true
  end

end
