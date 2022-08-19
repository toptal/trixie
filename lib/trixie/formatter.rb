# frozen_string_literal: true

module Trixie
  # Inlcludes the possible formats to output the secrets and the main entrypoint with Formatter.for(format)
  class Formatter
    FORMATTERS = {
      "env" => ->(secrets) { secrets.map { |secret| "#{secret["env"]}=#{secret["value"]}" }.join("\n") },
      "sh" => ->(secrets) { secrets.map { |secret| "export #{secret["env"]}=#{secret["value"]}" }.join("\n") },
      "json" => ->(secrets) { secrets.to_json },
      "pretty_json" => ->(secrets) { JSON.pretty_generate(secrets) }
    }.freeze

    def self.for(format)
      FORMATTERS[format]
    end
  end
end
