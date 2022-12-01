# frozen_string_literal: true

module Trixie
  # Fetches the specified secrets with op cli and returns them formatted
  class Load
    OP_NOT_INSTALLED = "op cli is not installed please download and install at https://developer.1password.com/docs/cli/get-started#install"
    OP_ADDRESS_ENV = "TRIXIE_OP_ADDRESS"
    OP_EMAIL_ENV = "TRIXIE_OP_EMAIL"

    def initialize(file:, groups: [], format: "env")
      @file = file
      @groups = groups
      @formatter = Formatter.for(format)
    end

    def call
      verify_op_installed!
      verify_secrets_config!

      create_account unless account_is_configured?

      fetch_secrets
    end

    def verify_op_installed!
      raise Trixie::OpCLINotInstalledError, OP_NOT_INSTALLED unless system("which op > /dev/null")
    end

    def verify_secrets_config!
      result = Trixie::Contracts::TrixieYml.new.call(secrets_config)

      raise Trixie::InvalidConfigError, "Invalid .trixie.yml: #{result.errors.to_h}" if result.errors.any?
    end

    def account_is_configured?
      !Open3.capture2("op account list").first.empty?
    end

    def create_account
      warn "* Configuring 1password Account"
      warn "To get the Secret Key take a look at https://support.1password.com/secret-key/"

      add_op_account
    end

    def fetch_secrets
      `eval $(op signin) && echo '#{formatted_secrets}' | op inject`
    end

    def secrets_config
      @secrets_config ||= YAML.load_file(@file)
    end

    def filtered_secrets
      return secrets_config["secrets"] if @groups.empty?

      secrets_config["secrets"].select { |secret| secret["groups"].any? { |group| @groups.include?(group) } }
    end

    def formatted_secrets
      @formatter.call(filtered_secrets)
    end

    def add_op_account
      cmd = "op account add"

      cmd += " --address #{ENV[OP_ADDRESS_ENV]}" if ENV[OP_ADDRESS_ENV]
      cmd += " --email #{ENV[OP_EMAIL_ENV]}" if ENV[OP_EMAIL_ENV]

      `#{cmd}`
    end
  end
end
