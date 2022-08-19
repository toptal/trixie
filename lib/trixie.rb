# frozen_string_literal: true

require "open3"
require "yaml"
require "json"
require "pathname"
require "dry/cli"

require_relative "trixie/version"
require_relative "trixie/template"
require_relative "trixie/formatter"
require_relative "trixie/load"
require_relative "trixie/cli"

module Trixie # rubocop:disable Style/Documentation
  class Error < StandardError; end
  class OpCLINotInstalled < Error; end

  class << self
    def root_path
      Pathname.new File.expand_path("#{__dir__}/..")
    end
  end
end
