# frozen_string_literal: true

module ECDSA
  module Ext
    # Representing a point on elliptic curves using projective coordinates.
    class ProjectivePoint < AbstractPoint
      include ProjectiveArithmetic

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
          return ProjectivePoint.infinity_point(group)
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
