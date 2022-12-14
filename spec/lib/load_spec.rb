# frozen_string_literal: true

RSpec.describe Trixie::Load do
  let(:instance) { described_class.new(**options) }
  let(:options) { { file: secrets_file, groups: secrets_groups, format: format } }
  let(:secrets_file) { Trixie.root_path.join("spec/fixture/.trixie.yml").to_s }
  let(:secrets_groups) { [] }
  let(:format) { "env" }

  describe "#call" do
    subject(:call) { instance.call }

    let(:fetched_secrets) do
      <<~SECRETS
        MY_SECRET=123
        MY_SECRET2=321
        BOOL_ENV=true
        NUMBER_ENV=12
      SECRETS
    end
    let(:formatted_secrets) do
      <<~FORMATTED_SECRETS
        MY_SECRET={{ op://Developers/MySecret/SETUP_SECRET/value }}
        MY_SECRET2={{ op://Developers/MySecret2/SETUP_SECRET/value }}
        BOOL_ENV=true
        NUMBER_ENV=12
      FORMATTED_SECRETS
        .chomp
    end
    let(:op_installed) { true }
    let(:op_account_list_output) { ["Account Information"] }

    before do
      allow(instance).to receive(:system).with("which op > /dev/null").and_return(op_installed).once
      allow(Open3).to receive(:capture2).with("op account list").and_return(op_account_list_output)
      allow(instance).to receive(:`).with("eval $(op signin) && echo '#{formatted_secrets}' | op inject")
                                    .and_return(fetched_secrets)
    end

    context "when op is not installed" do
      let(:op_installed) { false }

      it "returns the fetched secrets" do
        expect { call }.to raise_error(Trixie::OpCLINotInstalledError)
      end
    end

    context "when account is configured" do
      let(:op_account_list_output) { ["Account Information"] }

      it "returns the fetched secrets" do
        is_expected.to eq(fetched_secrets)
      end
    end

    context "when account is not configured" do
      let(:op_account_list_output) { [""] }

      context "and no email and address passed" do
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

      context "and email and address are passed as ENV variables" do
        let(:email) { "test.email@toptal.com" }
        let(:address) { "my.toptal.com" }

        before do
          allow(instance).to receive(:`).with("op account add --address #{address} --email #{email}")
          allow(ENV).to receive(:[]).with("TRIXIE_OP_EMAIL").and_return(email)
          allow(ENV).to receive(:[]).with("TRIXIE_OP_ADDRESS").and_return(address)
        end

        it "passess address and email as params" do
          call

          expect(instance).to have_received(:`)
            .with("op account add --address #{address} --email #{email}").once
        end

        it "returns the fetched secrets" do
          is_expected.to eq(fetched_secrets)
        end
      end
    end

    context "with groups specified" do
      let(:secrets_groups) { ["group2"] }
      let(:formatted_secrets) do
        <<~FORMATTED_SECRETS
          MY_SECRET2={{ op://Developers/MySecret2/SETUP_SECRET/value }}
        FORMATTED_SECRETS
          .chomp
      end
      let(:fetched_secrets) do
        <<~SECRETS
          MY_SECRET2=321
        SECRETS
      end

      it "only fetches the specifyied groups" do
        call

        expect(instance).to have_received(:`).with("eval $(op signin) && echo '#{formatted_secrets}' | op inject")
      end

      it "returns the secrets for that group" do
        is_expected.to eq(fetched_secrets)
      end
    end

    context "with a group without secrets" do
      let(:secrets_groups) { ["group10"] }
      let(:formatted_secrets) { "" }
      let(:fetched_secrets) { "" }

      it "returns an empty string" do
        is_expected.to eq("")
      end
    end

    context "with an invalid secret file" do
      let(:secrets_file) { Trixie.root_path.join("spec/fixture/.trixie_invalid.yml").to_s }

      it "raises an error" do
        expected_error_message = "Invalid .trixie.yml: " \
                                 '{:secrets=>{0=>{:env=>["must be a string"], :value=>["is missing"]}, ' \
                                 '1=>{:value=>["must be filled"], :groups=>["must be an array"]}}}'

        expect { call }.to raise_error(Trixie::InvalidConfigError, expected_error_message)
      end
    end
  end
end
