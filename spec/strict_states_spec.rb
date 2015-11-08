require 'spec_helper'

describe StrictStates do
  it "has a version number" do
    expect(StrictStates::VERSION).not_to be nil
  end

  context ".checker" do
    it "returns a module" do
      expect(StrictStates).to receive(:validate_config).and_return(true)
      expect(StrictStates.checker).to be_a Module
    end
    it "sets @strict_states_config" do
      expect(StrictStates).to receive(:validate_config).and_return(true)
      StrictStates.checker
      expect(StrictStates.instance_variable_defined?(:@strict_states_config)).to be true
    end
  end
end
