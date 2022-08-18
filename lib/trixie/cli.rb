# frozen_string_literal: true

module Trixie
  class CLI # rubocop:disable Style/Documentation
    extend Dry::CLI::Registry

    class Load < Dry::CLI::Command # rubocop:disable Style/Documentation
      desc 'Load envs'

      def call(*)
        puts 'Loading..'
      end
    end

    class Version < Dry::CLI::Command # rubocop:disable Style/Documentation
      desc 'Prints trixie version'

      def call(*)
        puts Trixie::VERSION
      end
    end

    register '--version', Version, aliases: ['-v']
    register 'load', Load, aliases: ['l']
  end
end
