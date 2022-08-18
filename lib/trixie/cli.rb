# frozen_string_literal: true

module Trixie
  class CLI # rubocop:disable Style/Documentation
    extend Dry::CLI::Registry

    class Load < Dry::CLI::Command # rubocop:disable Style/Documentation
      desc "Load envs"
      option :file, type: :string, default: ".trixie.yml", desc: "Secrets file", aliases: ["-f"]
      option :groups, type: :array, default: [], desc: "Secrets groups to consider", aliases: ["-g"]
      option :format, type: :string, default: "env", desc: "Format to output (env,json,pretty_json)"

      def call(**options)
        puts Trixie::Load.new(**options).call
      end
    end

    class Version < Dry::CLI::Command # rubocop:disable Style/Documentation
      desc "Prints trixie version"

      def call(*)
        puts Trixie::VERSION
      end
    end

    register "--version", Version, aliases: ["-v"]
    register "load", Load, aliases: ["l"]
  end
end
