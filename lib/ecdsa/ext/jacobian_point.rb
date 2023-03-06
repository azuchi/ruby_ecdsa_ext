# frozen_string_literal: true

module ECDSA
  module Ext
    # Point of Jacobian coordinates
    class JacobianPoint
      include JacobianArithmetic

      attr_reader :group, :x, :y, :z

      # Create new instance of jacobian
      # @param [ECDSA::Group] group
      # @param [Array] args [x, y, z]
      # @return [ECDSA::Ext::ProjectivePoint]
      def initialize(group, *args)
        @group = group
        @x, @y, @z = args
        raise ArgumentError, "Invalid x: #{x.inspect}" unless x.is_a?(Integer)
        raise ArgumentError, "Invalid y: #{y.inspect}" unless y.is_a?(Integer)
        raise ArgumentError, "Invalid z: #{z.inspect}" unless z.is_a?(Integer)
      end

      # Get filed of this group.
      # @return [ECDSA::PrimeField]
      def field
        group.field
      end

      # Convert coordinates from affine to projective.
      # @param [ECDSA::Point] point
      # @return [ECDSA::Ext::JacobianPoint]
      def self.from_affine(point)
        if point.infinity?
          JacobianPoint.infinity(point.group)
        else
          new(point.group, point.x, point.y, 1)
        end
      end

      # Create infinity point
      # @return [ECDSA::Ext::JacobianPoint]
      def self.infinity(group)
        # new(group, :infinity)
        new(group, 0, 1, 0)
      end

      # Check whether infinity point or not.
      # @return [Boolean]
      def infinity?
        x.zero? && y == 1 && z.zero?
      end

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

        if x == other.x && y == field.mod(-other.y) && z == other.z
          return JacobianPoint.infinity(group)
        end

        return other if y.zero? || z.zero?
        return self if other.y.zero? || other.z.zero?

        unless x == other.x
          if z == other.z
            return(
              z == 1 ? add_with_z_one(self, other) : add_with_z_eq(self, other)
            )
          end
          return add_with_z2_one(other, self) if z == 1
          return add_with_z2_one(self, other) if other.z == 1
          return add_with_z_ne(self, other)
        end

        return double if self == other
        raise "Failed to add #{inspect} to #{other.inspect}: No addition rules matched."
      end
      alias + add_to_point

      # Return the point added to itself.
      # @return [ECDSA::Ext::JacobianPoint]
      def double
        return self if infinity?

        return double_with_z_one(self) if z == 1

        xx = field.square(x)
        yy = field.square(y)
        yyyy = field.square(yy)
        zz = field.square(z)
        s = field.mod(2 * (field.square(x + yy) - xx - yyyy))
        m = field.mod(3 * xx + group.param_a * zz * zz)
        t = field.mod(m * m - 2 * s)
        y3 = field.mod(m * (s - t) - 8 * yyyy)
        z3 = field.mod(field.square(y + z) - yy - zz)
        JacobianPoint.new(group, t, y3, z3)
      end

      # Return the point multiplied by a non-negative integer.
      # @param [Integer] x
      # @return [ECDSA::Ext::JacobianPoint]
      def multiply_by_scalar(x)
        raise ArgumentError, "Scalar is not an integer." unless x.is_a?(Integer)
        raise ArgumentError, "Scalar is negative." if x.negative?

        q = JacobianPoint.infinity(group)
        v = self
        i = x
        while i.positive?
          q = q.add_to_point(v) if i.odd?
          v = v.double
          i >>= 1
        end
        q
      end
      alias * multiply_by_scalar

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

      # Return additive inverse of the point.
      # @return [ECDSA::Ext::ProjectivePoint]
      def negate
        return self if infinity?
        ProjectivePoint.new(group, x, field.mod(-y), z)
      end

      # Return coordinates.
      # @return [Array] (x, y , z)
      def coords
        [x, y, z]
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

      private

      def double_non_const
        return self if infinity?
        z == 1 ? double_z1 : double
      end

      def double_z1
        z3 = field.mod(2 * y)
        a = field.square(x)
        b = field.square(y)
        c = field.square(b)
        b = field.square(x + b)
        d = field.mod(2 * (b - (a + c)))
        e = field.mod(a * 3)
        f = field.square(e)
        x3 = field.mod(f - (2 * d))
        f = field.mod(d - x3)
        y3 = field.mod(e * f - 8 * c)
        JacobianPoint.new(group, x3, y3, z3)
      end
    end
  end
end
