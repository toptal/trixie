module Trixie
  class Formatter
    FORMATTERS = {
      "env" => ->(secrets) { secrets.map { |secret| "#{secret["env"]}=#{secret["value"]}" }.join("\n") },
      "json" => ->(secrets) { secrets.to_json },
      "pretty_json" => ->(secrets) { JSON.pretty_generate(secrets) }
    }.freeze

    def self.for(format)
      FORMATTERS[format]
    end
  end
end
