# frozen_string_literal: true
require_relative "ext/version"
require_relative "ext/point"
module ECDSA
  # Extension for ecdsa gem.
  module Ext
    autoload :AbstractPoint, "ecdsa/ext/abstract_point"
    autoload :ProjectivePoint, "ecdsa/ext/projective_point"
    autoload :JacobianPoint, "ecdsa/ext/jacobian_point"
  end
end
