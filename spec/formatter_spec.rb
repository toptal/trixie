# frozen_string_literal: true

RSpec.describe Trixie::Formatter do
  subject { formatter.call(secrets) }

  let(:formatter) { described_class.for(format) }
  let(:secrets) do
    [
      {
        "env" => "MY_SECRET1",
        "value" => "{{ op://Developers/MySecret/SETUP_SECRET/value }}",
        "groups" => ["test1"]
      },
      {
        "env" => "MY_SECRET2",
        "value" => "{{ op://Developers/MySecret2/SETUP_SECRET/value }}",
        "groups" => ["test2"]
      }
    ]
  end

  describe "env formatter" do
    let(:format) { "env" }

    it "returns the secrets in the env format" do
      is_expected.to eq(<<~RESULT.chomp)
        MY_SECRET1={{ op://Developers/MySecret/SETUP_SECRET/value }}
        MY_SECRET2={{ op://Developers/MySecret2/SETUP_SECRET/value }}
      RESULT
    end
  end

  describe "json formatter" do
    let(:format) { "json" }

    it "returns the secrets in the json format" do
      is_expected.to eq(secrets.to_json)
    end
  end

  describe "pretty json formatter" do
    let(:format) { "pretty_json" }

    it "returns the secrets in the pretty json format" do
      is_expected.to eq(<<~RESULT.chomp)
        [
          {
            "env": "MY_SECRET1",
            "value": "{{ op://Developers/MySecret/SETUP_SECRET/value }}",
            "groups": [
              "test1"
            ]
          },
          {
            "env": "MY_SECRET2",
            "value": "{{ op://Developers/MySecret2/SETUP_SECRET/value }}",
            "groups": [
              "test2"
            ]
          }
        ]
      RESULT
    end
  end
end
