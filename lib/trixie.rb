# frozen_string_literal: true

require 'dry/cli'
require 'open3'
require 'yaml'

require_relative "trixie/version"
require_relative "trixie/load"
require_relative "trixie/cli"

module Trixie
  class Error < StandardError; end
  # Your code goes here...
end
