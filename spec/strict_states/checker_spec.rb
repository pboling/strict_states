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

  context ".checker" do
    it("can be used with include") do
      expect {
        KlassWithFakeMachine.class_eval do
          include StrictStates.checker(
                      klass: self,
                      machines: {
                          state: :pluginaweek
                      }
                  )
        end
      }.to_not raise_error
    end
  end

end
