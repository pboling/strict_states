module StrictStates
  module Checker
    # Usage:
    #
    #   class MyModel < ActiveRecord::Base
    #     include StrictStates.checker(machines: [
    #       { name: :state, engine: :pluginaweek },
    #       { name: :awesome_level, engine: :pluginaweek }
    #       { name: :bogus_level, names_lookup: ->(context, machine_name) { context.state_machines[machine_name.to_sym].states} }
    #     ])
    #
    def self.included(base)
      # state_lookup ends up like this for a class with state machine(s):
      #
      #   MyModel.state_lookup
      #   =>  {
      #         :awesome_level =>
      #           { :not_awesome => "not_awesome", :awesome_11 => "awesome_11", :bad => "bad", :good => "good" },
      #         :bogus_level =>
      #           { :new => "new", :pending => "pending", :goofy => "goofy" }
      #       }
      base.send(:class_attribute, :strict_state_lookup)
      class << base
        attr_accessor :strict_state_lookup
      end
      base.strict_state_lookup ||= {}
      base.send(:extend, UtilityMethods)
      StrictStates.config[base.name].each do |machine|
        # User provided names_lookup lambda:
        #
        #   * future-proof support for any/all state machines
        #   * easily integrate with any state machine engine not already supported by this gem
        #
        raw_names = if machine[:names_lookup]
                      machine[:names_lookup].call(base, machine[:name])
                    elsif
                      StrictStates.engine_name_apis[machine[:engine]].call(base, machine[:name])
                    end
        StrictStates.strict_state_get_names(raw_names)
        names = StrictStates.strict_state_get_names(raw_names)
        base.strict_state_lookup[machine[:name].to_sym] = StrictStates.create_strict_state_lookup(names).freeze
      end
    end

    module ClassMethods
      # machine_name as :state is so universally common that it may as well be the default.
      # Most apps only use one state machine implementation, like aasm, or state_machines, however,
      #   apps can (and do) use multiple state machine implementations at the same time.
      # This gem supports that, and keeps all the states per-model, per-machine, per-engine separate!
      def state_lookup(machine_name: :state)
        strict_state_lookup[machine_name.to_sym]
      end
    end
  end
end
