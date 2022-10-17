# frozen_string_literal: true

RSpec.describe Trixie::Contracts::TrixieYml do
  let(:instance) { described_class.new }

  describe "#call" do
    subject(:result) { instance.call(config) }

    context "with a valid config" do
      let(:config) do
        {
          secrets: [
            {
              env: "MY_SECRET",
              value: "{{ op://Developers/MySecret/SETUP_SECRET/value }}",
              groups: ["group1"]
            }
          ]
        }
      end
      let(:config) { YAML.load_file(Trixie.root_path.join("spec/fixture/.trixie.yml").to_s) }

      it "validation pass" do
        is_expected.to be_success
      end
    end

    context "with a invalid config" do
      let(:config) { YAML.load_file(Trixie.root_path.join("spec/fixture/.trixie_invalid.yml").to_s) }
      let(:expected_errors) do
        {
          secrets: {
            0 => { env: ["must be a string"], value: ["is missing"] },
            1 => { groups: ["must be an array"], value: ["must be filled"] }
          }
        }
      end

      it "validation fails" do
        is_expected.to be_failure
      end

      it "returns the expected errors" do
        expect(result.errors.to_h).to eq(expected_errors)
      end
    end

    context "with an empty config" do
      let(:config) { {} }
      let(:expected_errors) do
        {
          secrets: ["is missing"]
        }
      end

      it "validation fails" do
        is_expected.to be_failure
      end

      it "returns the expected errors" do
        expect(result.errors.to_h).to eq(expected_errors)
      end
    end
  end
end
