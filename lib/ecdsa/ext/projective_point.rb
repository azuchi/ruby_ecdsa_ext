# frozen_string_literal: true

module ECDSA
  module Ext
    # Representing a point on elliptic curves using projective coordinates.
    class ProjectivePoint
      include PointArithmetic

      attr_reader :group, :x, :y, :z

      # Create new instance of projective
      # @param [ECDSA::Group] group
      # @param [Array] args [:infinity] or [x, y, z]
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
      # @return [ECDSA::Ext::ProjectivePoint]
      def self.from_affine(point)
        if point.infinity?
          ProjectivePoint.infinity(point.group)
        else
          new(point.group, point.x, point.y, 1)
        end
      end

      # Create infinity
      # @return [ECDSA::Ext::ProjectivePoint]
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

        # Implements complete addition for any curve
        if group.param_a == field.mod(-3)
          addition_negative3(self, other)
        else
          addition_any(self, other)
        end

        # t0 = field.mod(y * other.z)
        # t1 = field.mod(other.y * z)
        # u0 = field.mod(x * other.z)
        # u1 = field.mod(other.x * z)
        # return double if u0 == u1 && t0 == t1
        # t = field.mod(t0 - t1)
        # u = field.mod(u0 - u1)
        # u2 = field.mod(u * u)
        # v = field.mod(z * other.z)
        # w = field.mod(t * t * v - u2 * (u0 + u1))
        # u3 = field.mod(u * u2)
        # new_x = field.mod(u * w)
        # new_y = field.mod(t * (u0 * u2 - w) - t0 * u3)
        # new_z = field.mod(u3 * v)
        # ProjectivePoint.new(group, new_x, new_y, new_z)
      end
      alias + add_to_point

      # Return the point added to itself.
      # @return [ECDSA::Ext::ProjectivePoint]
      def double
        return self if infinity?

        if group.param_a == field.mod(-3)
          double_negative3(self)
        else
          double_any(self)
        end
      end

      # Convert this coordinates to affine coordinates.
      # @return [ECDSA::Point]
      def to_affine
        if infinity?
          group.infinity
        else
          ECDSA::Point.new(
            group,
            field.mod(x * field.inverse(z)),
            field.mod(y * field.inverse(z))
          )
        end
      end

      # Return the point multiplied by a non-negative integer.
      # @param [Integer] x
      # @return [ECDSA::Ext::ProjectivePoint]
      def multiply_by_scalar(x)
        raise ArgumentError, "Scalar is not an integer." unless x.is_a?(Integer)
        raise ArgumentError, "Scalar is negative." if x.negative?

        q = ProjectivePoint.infinity(group)
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

      # Return coordinates.
      # @return [Array] (x, y , z)
      def coords
        [x, y, z]
      end

      def ==(other)
        return false unless other.is_a?(ProjectivePoint)
        group == other.group && x == other.x && y == other.y && z == other.z
      end
    end
  end
end
