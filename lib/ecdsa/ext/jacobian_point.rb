# frozen_string_literal: true

module ECDSA
  module Ext
    # Point of Jacobian coordinates
    # http://point-at-infinity.org/ecc/Prime_Curve_Jacobian_Coordinates.html
    class JacobianPoint < AbstractPoint
      # Add this point to another point on the same curve.
      # @param [ECDSA::Ext::JacobianPoint] other
      # @return [ECDSA::Ext::JacobianPoint]
      def add_to_point(other)
        unless other.is_a?(JacobianPoint)
          raise ArgumentError, "other point must be instance of JacobianPoint"
        end
        unless other.group == group
          raise ArgumentError, "other group must be same group of this point"
        end

        return other if infinity?
        return self if other.infinity?

        u1 = field.mod(x * field.power(other.z, 2))
        u2 = field.mod(other.x * field.power(z, 2))
        s1 = field.mod(y * field.power(other.z, 3))
        s2 = field.mod(other.y * field.power(z, 3))

        return s1 == s2 ? double : infinity_point if u1 == u2

        h = field.mod(u2 - u1)
        h2 = field.power(h, 2)
        h3 = field.power(h, 3)
        r = field.mod(s2 - s1)
        x3 = field.mod(field.power(r, 2) - h3 - 2 * u1 * h2)
        y3 = field.mod(r * (u1 * h2 - x3) - s1 * h3)
        z3 = field.mod(h * z * other.z)
        JacobianPoint.new(group, x3, y3, z3)
      end
      alias + add_to_point

      # Return the point added to itself.
      # @return [ECDSA::Ext::JacobianPoint]
      def double
        return self if infinity?
        return infinity_point if y.zero?

        s = field.mod(4 * x * field.power(y, 2))
        m = field.mod(3 * field.power(x, 2) + group.param_a * field.power(z, 4))
        x3 = field.mod(field.power(m, 2) - 2 * s)
        y3 = field.mod(m * (s - x3) - 8 * field.power(y, 4))
        z3 = field.mod(2 * y * z)
        JacobianPoint.new(group, x3, y3, z3)
      end

      # Convert this coordinates to affine coordinates.
      # @return [ECDSA::Point]
      def to_affine
        if infinity?
          group.infinity
        else
          z_inv = field.inverse(z)
          tmp_z = field.square(z_inv)
          new_x = field.mod(x * tmp_z) # x = x * (1/z)^2
          new_y = field.mod(y * tmp_z * z_inv) # y = y * (1/z)^3
          ECDSA::Point.new(group, new_x, new_y)
        end
      end

      # Check whether same jacobian point or not.
      # @param [ECDSA::Ext::JacobianPoint] other
      # @return [Boolean]
      def ==(other)
        return false unless other.is_a?(JacobianPoint)
        return true if infinity? && other.infinity?

        zz = field.square(z)
        other_zz = field.square(other.z)
        lhs_x = field.mod(x * other_zz)
        rhs_x = field.mod(other.x * zz)
        lhs_y = field.mod(y * other_zz * other.z)
        rhs_y = field.mod(other.y * zz * z)

        lhs_x == rhs_x && lhs_y == rhs_y
      end
    end
  end
end
