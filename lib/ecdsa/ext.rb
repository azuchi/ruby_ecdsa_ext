# frozen_string_literal: true
require_relative "ext/version"
module ECDSA
  # Extension for ecdsa gem.
  module Ext
    autoload :PointArithmetic, "ecdsa/ext/point_arithmetic"
    autoload :ProjectivePoint, "ecdsa/ext/projective_point"
  end
end
