# frozen_string_literal: true

RSpec.describe Trixie::Load do
  let(:instance) { described_class.new(**options) }
  let(:options) { { file: secrets_file } }
  let(:secrets_file) { Trixie.root_path.join("spec/fixture/.trixie.yml").to_s }

  describe "#call" do
    subject(:call) { instance.call }

    let(:fetched_secrets) do
      <<~SECRETS
        MY_SECRET=123
        MY_SECRET2=321
      SECRETS
    end

    let(:formatted_secrets) do
      <<~FORMATTED_SECRETS
        MY_SECRET={{ op://Developers/MySecret/SETUP_SECRET/value }}
        MY_SECRET2={{ op://Developers/MySecret2/SETUP_SECRET/value }}
      FORMATTED_SECRETS
        .chomp
    end

    before do
      allow(Open3).to receive(:capture2).with("op account list").and_return(op_account_list_output)
      allow(instance).to receive(:`).with("eval $(op signin) && echo '#{formatted_secrets}' | op inject").and_return(fetched_secrets)
    end

    context "when account is configured" do
      let(:op_account_list_output) { ["Not Empty"] }

      it "returns the fetched secrets" do
        is_expected.to eq(fetched_secrets)
      end
    end

    context "when account is not configured" do
      let(:op_account_list_output) { [""] }

      before do
        allow(instance).to receive(:`).with("op account add")
      end

      it "creates an account" do
        call
        expect(instance).to have_received(:`).with("op account add").once
      end

      it "returns the fetched secrets" do
        is_expected.to eq(fetched_secrets)
      end
    end
  end
end
