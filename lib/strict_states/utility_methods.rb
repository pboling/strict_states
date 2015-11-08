module StrictStates
  module UtilityMethods

    # Given a state return the same state if they are valid for the given state machine,
    #   otherwise raise an error
    #
    # Example:
    #
    #   MyModel.strict_state(:good, machine_name: :state)
    #   => "good"
    #   MyModel.strict_state(:not_actually_a_thing, machine_name: :drive_status) # Can support multiple state machines per model
    #   => KeyError: key not found: :not_actually_a_thing
    #
    # This is better than creating discrete constants for each potential state string in a state machine,
    #   because this checks, at app boot, to ensure the states are correct.
    #   (e.g. "gift card", vs "gift_card").
    #
    def strict_state(state, machine_name: :state)
      strict_state_lookup[machine_name.to_sym][state.to_sym] # This will raise an error if the state key is not a valid state
    end

    # Given an array of states return the same array of states if they are valid for the given state machine,
    #   otherwise raise an error
    #
    # Example:
    #
    #   MyModel.strict_state_array(:good, :bad, :on_hold, machine_name: :state)
    #   => ["good", "bad", "on_hold"]
    #   MyModel.strict_state(:good, :bad, :steve_martin, machine_name: :drive_status) # Can support multiple state machines per model
    #   => KeyError: key not found: :steve_martin
    #
    # This is better than creating discrete constants for each potential set of states in a state machine,
    #   because this checks, at app boot, to ensure the states are correct.
    # Raw strings in scopes and queries, not created via this method,
    #   will not be bound to the state machine's implementation, so they will fail silently.
    #   e.g. typos like "gift card" vs "gift_card" and no error raised
    #
    def strict_state_array(*names, machine_name: :state)
      names.map {|state| strict_state(state, machine_name: machine_name) }
    end

    # Given the name of a state machine, returns all states defined by the state machine, as an array of strings.
    def strict_all_state_names(machine_name: :state)
      strict_state_lookup[machine_name.to_sym].values # keys would be symbols!
    end

  end
end
