# frozen_string_literal: true

module ECDSA
  module Ext
    # Representing a point on elliptic curves using projective coordinates.
    # http://point-at-infinity.org/ecc/Prime_Curve_Standard_Projective_Coordinates.html
    class ProjectivePoint < AbstractPoint
      # Add this point to another point on the same curve.
      # @param [ECDSA::Ext::ProjectivePoint] other
      # @return [ECDSA::Ext::ProjectivePoint]
      def add_to_point(other)
        unless other.is_a?(ProjectivePoint)
          raise ArgumentError, "other point must be instance of ProjectivePoint"
        end
        unless other.group == group
          raise ArgumentError, "other group must be same group of this point"
        end

        return other if infinity?
        return self if other.infinity?

        u1 = field.mod(other.y * z)
        u2 = field.mod(y * other.z)
        v1 = field.mod(other.x * z)
        v2 = field.mod(x * other.z)
        return u1 == u2 ? double : infinity_point if v1 == v2
        u = field.mod(u1 - u2)
        v = field.mod(v1 - v2)
        vv = field.power(v, 2)
        vvv = field.power(v, 3)
        w = field.mod(z * other.z)
        a = field.mod(field.power(u, 2) * w - vvv - 2 * vv * v2)
        x3 = field.mod(v * a)
        y3 = field.mod(u * (vv * v2 - a) - vvv * u2)
        z3 = field.mod(vvv * w)
        ProjectivePoint.new(group, x3, y3, z3)
      end
      alias + add_to_point

      # Return the point added to itself.
      # @return [ECDSA::Ext::ProjectivePoint]
      def double
        return self if infinity?
        return infinity_point if y.zero?

        w = field.mod(group.param_a * field.power(z, 2) + 3 * field.power(x, 2))
        s = field.mod(y * z)
        b = field.mod(x * y * s)
        h = field.mod(field.power(w, 2) - 8 * b)
        x3 = field.mod(2 * h * s)
        y3 =
          field.mod(w * (4 * b - h) - 8 * field.power(y, 2) * field.power(s, 2))
        z3 = field.mod(8 * field.power(s, 3))
        ProjectivePoint.new(group, x3, y3, z3)
      end

      # Convert this coordinates to affine coordinates.
      # @return [ECDSA::Point]
      def to_affine
        if infinity?
          group.infinity
        else
          z_inv = field.inverse(z)
          ECDSA::Point.new(group, field.mod(x * z_inv), field.mod(y * z_inv))
        end
      end

      def ==(other)
        return false unless other.is_a?(ProjectivePoint)
        return true if infinity? && other.infinity?

        lhs_x = field.mod(x * other.z)
        rhs_x = field.mod(other.x * z)
        lhs_y = field.mod(y * other.z)
        rhs_y = field.mod(other.y * z)

        lhs_x == rhs_x && lhs_y == rhs_y
      end
    end
  end
end
