# frozen_string_literal: true

module Trixie
  module Contracts
    # class to validate .trixie.yml files
    # Usage:
    #   config_contract = Trixie::Contracts::TrixieYml.new
    #   result = config_contract.call(config_options)
    #   result.sucess?
    #   result.errors.to_h
    class TrixieYml < Dry::Validation::Contract
      params do
        required(:secrets).array(:hash) do
          required(:env).filled(:string)
          required(:value).filled(Types::Strict::String | Types::Strict::Bool | Types::Strict::Integer)
          required(:groups).array(:string)
        end
      end
    end
  end
end
