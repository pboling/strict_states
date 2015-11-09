require "spec_helper"

describe StrictStates do

  class Car; end

  it "has a version number" do
    expect(StrictStates::VERSION).not_to be nil
  end

  context ".checker" do
    context "API" do
      before do
        expect(StrictStates).to receive(:validate_config).and_return(true)
        expect(StrictStates).to receive(:states_for_machines).and_return({})
        expect(StrictStates).to receive(:set_strict_state_lookup).and_return(true)
      end
      it "returns a module" do
        expect(StrictStates.checker).to be_a Module
      end
      it "module is StrictStates::Checker" do
        expect(StrictStates.checker).to eq ::StrictStates::Checker
      end
      context "arguments" do
        it "accepts namespaced" do
          expect { StrictStates.checker(klass: Car, machines: {}) }.to_not raise_error
        end
      end
    end
  end

  context ".validate_config" do
    context "complete config" do
      it "does not raise" do
        expect { StrictStates.send(:validate_config, klass: Car, machines: {bar: :aasm}) }.to_not raise_error
      end
    end
    context "incomplete config" do
      context "missing" do
        context "klass" do
          it "raises" do
            expect { StrictStates.send(:validate_config, machines: {bar: :aasm}) }.to raise_error ArgumentError, /:klass/
          end
        end
        context "machines" do
          it "raises" do
            expect { StrictStates.send(:validate_config, klass: Car) }.to raise_error ArgumentError, /:machines/
          end
        end
      end
      context "invalid" do
        context "klass" do
          it "raises" do
            expect { StrictStates.send(:validate_config, klass: "Car", machines: {bar: :aasm}) }.to raise_error ArgumentError, /:klass/
          end
        end
        context "machines" do
          it "raises" do
            expect { StrictStates.send(:validate_config, klass: Car, machines: [{bar: :aasm}]) }.to raise_error ArgumentError, /:machines/
          end
        end
      end
    end
  end

  context ".states_for_machines" do
    let(:states) { %w(one two three) }
    before do
      expect(StrictStates).to receive(:get_proc_for_engine).and_return(Proc.new { states })
    end
    it "does not raise" do
      expect { StrictStates.send(:states_for_machines, Car, {bar: :aasm}) }.to_not raise_error
    end
    it "returns a hash" do
      expect(StrictStates.send(:states_for_machines, Car, {bar: :aasm})).to be_a Hash
    end
    it "has states" do
      expect(StrictStates.send(:states_for_machines, Car, {bar: :aasm})).to eq({bar: states})
    end
  end

  context ".states_for_machines" do
    let(:state_states) { %i(one two three) }
    let(:awesome_level_states) { ["not_awesome", "awesome_11", "bad", "good"] }
    let(:bogus_level_states) { ["new", "pending", "goofy"] }
    let(:other_level_states) { ["dog", "cat", "monkey"] }
    let(:got_sate_states) { ["apple", "grape", "pear"] }
    before do
      expect(StrictStates).to receive(:get_proc_for_engine).with(:pluginaweek).and_return(Proc.new { state_states })
      expect(StrictStates).to receive(:get_proc_for_engine).with(:seuros).and_return(Proc.new { awesome_level_states })
      expect(StrictStates).to receive(:get_proc_for_engine).with(:state_machines).and_return(Proc.new { bogus_level_states })
      expect(StrictStates).to receive(:get_proc_for_engine).with(:aasm).and_return(Proc.new { bogus_level_states })
      expect(StrictStates).to receive(:get_proc_for_engine).with(:aasm_multiple).and_return(Proc.new { bogus_level_states })
    end
    it "does not raise" do
      expect { StrictStates.send(:states_for_machines,
                                 Car,
                                 {
                                     state:           :pluginaweek,
                                     awesome_level:   :seuros,
                                     bogus_level:     :state_machines,
                                     other_level:     :aasm,
                                     got_sate:        :aasm_multiple
                                 }) }.to_not raise_error
    end
    it "returns hash with array of states for each machine" do
      expect(StrictStates.send(:states_for_machines,
                                 Car,
                                 {
                                   state:           :pluginaweek,
                                   awesome_level:   :seuros,
                                   bogus_level:     :state_machines,
                                   other_level:     :aasm,
                                   got_sate:        :aasm_multiple
                                 })).to eq({
                                               state: ["one", "two", "three"],
                                               awesome_level: ["not_awesome", "awesome_11", "bad", "good"],
                                               bogus_level: ["new", "pending", "goofy"],
                                               other_level: ["new", "pending", "goofy"],
                                               got_sate: ["new", "pending", "goofy"]
                                           })
    end
  end

  context ".set_strict_state_lookup" do
    let(:state_states) { %i(one two three) }
    let(:awesome_level_states) { ["not_awesome", "awesome_11", "bad", "good"] }
    let(:bogus_level_states) { ["new", "pending", "goofy"] }
    let(:config) {
      {
          klass: Car, # any Class object with a state machine
          machines: { # the machine names, and states defined within each
                      state:          state_states,
                      awesome_level:  awesome_level_states,
                      bogus_level:    bogus_level_states
          }
      }
    }
    let(:strict_state_lookup) { Car.strict_state_lookup }
    it "does not raise" do
      expect { StrictStates.send(:set_strict_state_lookup, config) }.to_not raise_error
    end
    context "when called" do
      before { StrictStates.send(:set_strict_state_lookup, config) }
      it "sets @strict_state_lookup" do
        expect(Car.instance_variable_defined?(:@strict_state_lookup)).to be true
      end
      it "creates accessor method" do
        expect(strict_state_lookup).to be_a Hash
      end
      context "klass.strict_state_lookup" do
        it "is set to a Hash" do
          expect(strict_state_lookup).to be_a Hash
        end
        context "has keys for" do
          it "all machine names" do
            expect(strict_state_lookup.keys).to eq([:state, :awesome_level, :bogus_level])
          end
          it "each state in each machine" do
            state_states.each do |state_name|
              expect(strict_state_lookup[:state]).to have_key(state_name.to_sym)
            end
            awesome_level_states.each do |state_name|
              expect(strict_state_lookup[:awesome_level]).to have_key(state_name.to_sym)
            end
            bogus_level_states.each do |state_name|
              expect(strict_state_lookup[:bogus_level]).to have_key(state_name.to_sym)
            end
          end
        end
      end
    end
  end

end
