# frozen_string_literal: true

module ECDSA
  # Extension of ECDSA::Point class.
  class Point
    # Convert coordinates to projective point.
    # @return [ECDSA::Ext::ProjectivePoint]
    def to_projective
      ECDSA::Ext::ProjectivePoint.from_affine(self)
    end
  end
end
