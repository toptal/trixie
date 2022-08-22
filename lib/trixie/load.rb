# frozen_string_literal: true

module Trixie
  # Fetches the specified secrets with op cli and returns them formatted
  class Load
    OP_NOT_INSTALLED = "op cli is not installed please download and install at https://developer.1password.com/docs/cli/get-started#install"

    def initialize(file:, groups: [], format: "env")
      @file = file
      @groups = groups
      @formatter = Formatter.for(format)
    end

    def call
      verify_op_installed!

      create_account unless account_is_configured?

      fetch_secrets
    end

    def verify_op_installed!
      raise Trixie::OpCLINotInstalled, OP_NOT_INSTALLED unless system("which op > /dev/null")
    end

    def account_is_configured?
      !Open3.capture2("op account list").first.empty?
    end

    def create_account
      warn "* Configuring 1password Account"
      warn "To get the Secret Key take a look at https://support.1password.com/secret-key/"

      `op account add`
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
  end
end
