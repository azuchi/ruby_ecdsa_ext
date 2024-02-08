# frozen_string_literal: true

module ECDSA
  # Extension of ECDSA::Point class.
  class Point
    # Convert coordinates to projective point.
    # @return [ECDSA::Ext::ProjectivePoint]
    def to_projective
      ECDSA::Ext::ProjectivePoint.from_affine(self)
    end

    # Convert coordinates to projective point.
    # @return [ECDSA::Ext::JacobianPoint]
    def to_jacobian
      ECDSA::Ext::JacobianPoint.from_affine(self)
    end

    # Convert coordinates to hex string.
    # @return [String]
    def to_hex(compression = true) # rubocop:disable all
      ECDSA::Format::PointOctetString.encode(
        self,
        compression: compression
      ).unpack1("H*")
    end
  end
end
