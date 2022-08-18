# frozen_string_literal: true

module Trixie
  class Load
    OP_NOT_INSTALLED = "op cli is not installed please download and install at https://developer.1password.com/docs/cli/get-started#install"

    def initialize(file:)
      @file = file
    end

    def call
      verify_op_installed!

      create_account unless account_is_configured?

      fetch_secrets
    end

    def verify_op_installed!
      raise Trixie::Error, OP_NOT_INSTALLED unless system("which op > /dev/null")
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

    def formatted_secrets
      secrets_config["secrets"].map { |secret| "#{secret["env"]}=#{secret["value"]}" }.join("\n")
    end
  end
end
