# frozen_string_literal: true
require_relative "ext/version"
require_relative "ext/point"
module ECDSA
  # Extension for ecdsa gem.
  module Ext
    autoload :ProjectiveArithmetic, "ecdsa/ext/projective_arithmetic"
    autoload :ProjectivePoint, "ecdsa/ext/projective_point"
  end
end
