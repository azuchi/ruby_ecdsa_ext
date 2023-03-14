# frozen_string_literal: true

module ECDSA
  module Ext
    # Abstract class of point
    class AbstractPoint
      attr_reader :group, :x, :y, :z, :infinity

      # Create new instance.
      # @param [ECDSA::Group] group
      # @param [Array] args [x, y, z]
      # @return [ECDSA::Ext::AbstractPoint]
      def initialize(group, *args)
        @group = group
        if args == [:infinity]
          @infinity = true
        else
          @infinity = false
          @x, @y, @z = args
          raise ArgumentError, "Invalid x: #{x.inspect}" unless x.is_a?(Integer)
          raise ArgumentError, "Invalid y: #{y.inspect}" unless y.is_a?(Integer)
          raise ArgumentError, "Invalid z: #{z.inspect}" unless z.is_a?(Integer)
        end
      end

      # Get filed of this group.
      # @return [ECDSA::PrimeField]
      def field
        group.field
      end

      # Convert coordinates from affine.
      # @param [ECDSA::Point] point
      # @return [ECDSA::Ext::AbstractPoint]
      def self.from_affine(point)
        if point.infinity?
          infinity_point(point.group)
        else
          new(point.group, point.x, point.y, 1)
        end
      end

      # Create infinity point
      # @return [ECDSA::Ext::AbstractPoint]
      def self.infinity_point(group)
        new(group, :infinity)
      end

      # Check whether infinity point or not.
      # @return [Boolean]
      def infinity?
        @infinity
      end

      # Return additive inverse of the point.
      # @return [ECDSA::Ext::AbstractPoint]
      def negate
        return self if infinity?
        self.class.new(group, x, field.mod(-y), z)
      end

      # Return coordinates.
      # @return [Array] (x, y , z)
      def coords
        [x, y, z]
      end

      # Return the point multiplied by a non-negative integer.
      # @param [Integer] x
      # @return [ECDSA::Ext::ProjectivePoint]
      def multiply_by_scalar(x)
        raise ArgumentError, "Scalar is not an integer." unless x.is_a?(Integer)
        raise ArgumentError, "Scalar is negative." if x.negative?

        q = self.class.infinity_point(group)
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

      def add_to_point(other)
        raise NotImplementedError
      end

      def double
        raise NotImplementedError
      end

      def to_affine
        raise NotImplementedError
      end

      def ==(other)
        raise NotImplementedError
      end
    end
  end
end
