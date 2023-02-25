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

        if x == other.x && y == field.mod(-other.y) && z == other.z
          return ProjectivePoint.infinity(group)
        end

        unless x == other.x
          return(
            (
              if group.param_a == field.mod(-3)
                addition_negative3(self, other)
              else
                addition_any(self, other)
              end
            )
          )
        end

        return double if self == other
        raise "Failed to add #{inspect} to #{other.inspect}: No addition rules matched."
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
