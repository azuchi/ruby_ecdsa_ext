# frozen_string_literal: true
module ECDSA
  module Ext
    # Point arithmetic implementation
    module JacobianArithmetic
      def add_with_z_one(a, b)
        field = a.field
        h = field.mod(b.x - a.x)
        hh = field.square(h)
        i = field.mod(4 * hh)
        j = field.mod(h * i)
        r = field.mod(2 * (b.y - a.y))
        return double_with_z_one(a) if h.zero? && r.zero?
        v = field.mod(a.x * i)
        x3 = field.mod(field.square(r) - j - 2 * v)
        y3 = field.mod(r * (v - x3) - 2 * a.y * j)
        z3 = field.mod(2 * h)
        JacobianPoint.new(a.group, x3, y3, z3)
      end

      def add_with_z_eq(a, b)
        field = a.field
        a = field.square(field.mod(b.x - a.x))
        b = field.mod(a.x * a)
        c = field.mod(b.x * a)
        d = field.square(field.mod(b.y - a.y))
        return double(a) if a.zero? && d.zero?
        x3 = field.mod(d - b - c)
        y3 = field.mod((b.y - a.y) * (b - x3) - a.y * (c - b))
        z3 = field.mod(a.z * (b.x - a.x))
        JacobianPoint.new(a.group, x3, y3, z3)
      end

      def add_with_z2_one(a, b)
        field = a.field
        z1z1 = field.square(a.z)
        u2 = field.mod(b.x * z1z1)
        s2 = field.mod(b.y * a.z * z1z1)
        h = field.mod(u2 - a.x)
        hh = field.square(h)
        i = field.mod(4 * hh)
        j = field.mod(h * i)
        r = field.mod(2 * (s2 - a.y))
        return double_with_z_one(b) if r.zero? && h.zero?
        v = field.mod(a.x * i)
        x3 = field.mod(r * r - j - 2 * v)
        y3 = field.mod(r * (v - x3) - 2 * a.y * j)
        z3 = field.mod(field.square(a.z + h) - z1z1 - hh)
        JacobianPoint.new(a.group, x3, y3, z3)
      end

      def add_with_z_ne(a, b)
        field = a.field
        z1z1 = field.square(a.z)
        z2z2 = field.square(b.z)
        u1 = field.mod(a.x * z2z2)
        u2 = field.mod(b.x * z1z1)
        s1 = field.mod(a.y * b.z * z2z2)
        s2 = field.mod(b.y * a.z * z1z1)
        h = field.mod(u2 - u1)
        i = field.mod(4 * h * h)
        j = field.mod(h * i)
        r = field.mod(2 * (s2 - s1))
        return double(a) if h.zero? && r.zero?
        v = field.mod(u1 * i)
        x3 = field.mod(r * r - j - 2 * v)
        y3 = field.mod(r * (v - x3) - 2 * s1 * j)
        z3 = field.mod((field.square(a.z + b.z) - z1z1 - z2z2) * h)
        JacobianPoint.new(a.group, x3, y3, z3)
      end

      def double_with_z_one(point)
        field = point.field
        xx = field.square(point.x)
        yy = field.square(point.y)
        yyyy = field.square(yy)
        s = field.mod(2 * (field.square(point.x + yy) - xx - yyyy))
        m = field.mod(3 * xx + point.group.param_a)
        t = field.mod(m * m - 2 * s)
        y3 = field.mod(m * (s - t) - 8 * yyyy)
        z3 = field.mod(2 * point.y)
        JacobianPoint.new(point.group, t, y3, z3)
      end
    end
  end
end
