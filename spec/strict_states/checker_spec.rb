require "spec_helper"

describe StrictStates::Checker do

  class KlassWithFakeMachine
    def self.state_machines
      FakeMachine.new
    end

    class FakeMachine
      def [](_)
        FakeStates.new
      end
    end

    FakeState = Struct.new(:name)
    class FakeStates
      def states
        [FakeState.new("Mad"), FakeState.new("Max")]
      end
    end
  end

  let(:klass) {
    KlassWithFakeMachine.class_eval do
      include StrictStates.checker(
                  klass: self,
                  machines: {
                      state: :pluginaweek
                  }
              )
    end
  }

  context ".included" do
    it("can be used with include") do
      expect { klass }.to_not raise_error
    end
    context "adds methods to klass" do
      it "responds to state_lookup" do
        expect(klass).to respond_to(:state_lookup)
      end
      it "responds to state_lookup" do
        expect(klass).to respond_to(:strict_state)
      end
      it "responds to state_lookup" do
        expect(klass).to respond_to(:strict_state_array)
      end
      it "responds to state_lookup" do
        expect(klass).to respond_to(:strict_all_state_names)
      end
    end
  end

  context "klass.strict_all_state_names" do
    context "no arguments" do
      it "returns an array" do
        expect(klass.strict_all_state_names).to eq(%w(Mad Max))
      end
    end
    context "optional valid arguments" do
      it "returns an array" do
        expect(klass.strict_all_state_names(machine_name: :state)).to eq(%w(Mad Max))
      end
    end
    context "optional invalid arguments" do
      it "raises an error" do
        expect { klass.strict_all_state_names(machine_name: :lunch) }.to raise_error KeyError, "key not found: :lunch"
      end
    end
  end
end
