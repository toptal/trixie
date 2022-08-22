# frozen_string_literal: true

RSpec.describe Trixie::Template do
  subject { formatter.call(secrets) }

  describe ".render" do
    subject(:render) { described_class.render(template_name, to: destination) }

    let(:template_name) { "default" }
    let(:destination) { tmp_folder.join("template_test").to_s }
    let(:tmp_folder) { Pathname.new("tmp/") }

    around do |example|
      tmp_folder.mkdir unless tmp_folder.exist?
      example.run
      File.delete(destination)
    end

    it "renders the template" do
      render

      destination_content = File.read(destination)
      template_content = Trixie.root_path.join("lib/trixie/templates/#{template_name}").read

      expect(destination_content).to eq(template_content)
    end
  end
end
