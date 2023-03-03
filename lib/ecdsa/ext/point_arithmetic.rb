# frozen_string_literal: true
module ECDSA
  module Ext
    # Point arithmetic implementation
    module PointArithmetic
      def addition_negative3(a, b)
        field = a.field
        xx = field.mod(a.x * b.x)
        yy = field.mod(a.y * b.y)
        zz = field.mod(a.z * b.z)
        xy_pairs = field.mod((a.x + a.y) * (b.x + b.y) - (xx + yy))
        yz_pairs = field.mod((a.y + a.z) * (b.y + b.z) - (yy + zz))
        xz_pairs = field.mod((a.x + a.z) * (b.x + b.z) - (xx + zz))

        bzz_part = field.mod(xz_pairs - a.group.param_b * zz)
        bzz3_part = field.mod(bzz_part * 2 + bzz_part)
        yy_m_bzz3 = field.mod(yy - bzz3_part)
        yy_p_bzz3 = field.mod(yy + bzz3_part)

        zz3 = field.mod(zz * 3)
        bxz_part = field.mod(a.group.param_b * xz_pairs - (zz3 + xx))
        bxz3_part = field.mod(bxz_part * 3)
        xx3_m_zz3 = field.mod(xx * 3 - zz3)

        x = field.mod(yy_p_bzz3 * xy_pairs - yz_pairs * bxz3_part)
        y = field.mod(yy_p_bzz3 * yy_m_bzz3 + xx3_m_zz3 * bxz3_part)
        z = field.mod(yy_m_bzz3 * yz_pairs + xy_pairs * xx3_m_zz3)
        ProjectivePoint.new(a.group, x, y, z)
      end

      def addition_any(a, b)
        field = a.field
        b3 = field.mod(3 * group.param_b)
        t0 = field.mod(a.x * b.x)
        t1 = field.mod(a.y * b.y)
        t2 = field.mod(a.z * b.z)
        t3 = field.mod(a.x + a.y)
        t4 = field.mod(b.x + b.y)
        t3 = field.mod(t3 * t4)
        t4 = field.mod(t0 + t1)
        t3 = field.mod(t3 - t4)
        t4 = field.mod(a.x + a.z)
        t5 = field.mod(b.x + b.z)
        t4 = field.mod(t4 * t5)
        t5 = field.mod(t0 + t2)
        t4 = field.mod(t4 - t5)
        t5 = field.mod(a.y + a.z)
        x3 = field.mod(b.y + b.z)
        t5 = field.mod(t5 * x3)
        x3 = field.mod(t1 + t2)
        t5 = field.mod(t5 - x3)
        z3 = field.mod(a.group.param_a * t4)
        x3 = field.mod(b3 * t2)
        z3 = field.mod(x3 + z3)
        x3 = field.mod(t1 - z3)
        z3 = field.mod(t1 + z3)
        y3 = field.mod(x3 * z3)
        t1 = field.mod(t0 + t0)
        t1 = field.mod(t1 + t0)
        t2 = field.mod(a.group.param_a * t2)
        t4 = field.mod(b3 * t4)
        t1 = field.mod(t1 + t2)
        t2 = field.mod(t0 - t2)
        t2 = field.mod(a.group.param_a * t2)
        t4 = field.mod(t4 + t2)
        t0 = field.mod(t1 * t4)
        y3 = field.mod(y3 + t0)
        t0 = field.mod(t5 * t4)
        x3 = field.mod(t3 * x3)
        x3 = field.mod(x3 - t0)
        t0 = field.mod(t3 * t1)
        z3 = field.mod(t5 * z3)
        z3 = field.mod(z3 + t0)
        ProjectivePoint.new(a.group, x3, y3, z3)
      end

      def double_negative3(point)
        field = point.field
        xx = field.square(point.x)
        yy = field.square(point.y)
        zz = field.square(point.z)
        xy2 = field.mod(point.x * point.y * 2)
        xz2 = field.mod(point.x * point.z * 2)

        bzz_part = field.mod(point.group.param_b * zz - xz2)
        bzz3_part = field.mod(bzz_part + bzz_part + bzz_part)
        yy_m_bzz3 = field.mod(yy - bzz3_part)
        yy_p_bzz3 = field.mod(yy + bzz3_part)
        y_frag = field.mod(yy_p_bzz3 * yy_m_bzz3)
        x_frag = field.mod(yy_m_bzz3 * xy2)

        zz3 = field.mod(zz * 3)
        bxz2_part = field.mod(point.group.param_b * xz2 - (zz3 + xx))
        bxz6_part = field.mod(bxz2_part * 3)
        xx3_m_zz3 = field.mod(xx * 3 - zz3)

        y = field.mod(y_frag + xx3_m_zz3 * bxz6_part)
        yz2 = field.mod(point.y * point.z * 2)
        x = field.mod(x_frag - bxz6_part * yz2)
        z = field.mod(yz2 * yy * 4)
        ProjectivePoint.new(point.group, x, y, z)
      end

      def double_any(point)
        field = point.field
        b3 = field.mod(point.group.param_b * 3)

        t0 = field.mod(point.x * point.x)
        t1 = field.mod(point.y * point.y)
        t2 = field.mod(point.z * point.z)
        t3 = field.mod(point.x * point.y)
        t3 = field.mod(t3 + t3)
        z3 = field.mod(point.x * point.z)
        z3 = field.mod(z3 + z3)
        x3 = field.mod(point.group.param_a * z3)
        y3 = field.mod(b3 * t2)
        y3 = field.mod(x3 + y3)
        x3 = field.mod(t1 - y3)
        y3 = field.mod(t1 + y3)
        y3 = field.mod(x3 * y3)
        x3 = field.mod(t3 * x3)
        z3 = field.mod(b3 * z3)
        t2 = field.mod(point.group.param_a * t2)
        t3 = field.mod(t0 - t2)
        t3 = field.mod(point.group.param_a * t3)
        t3 = field.mod(t3 + z3)
        z3 = field.mod(t0 + t0)
        t0 = field.mod(z3 + t0)
        t0 = field.mod(t0 + t2)
        t0 = field.mod(t0 * t3)
        y3 = field.mod(y3 + t0)
        t2 = field.mod(point.y * point.z)
        t2 = field.mod(t2 + t2)
        t0 = field.mod(t2 * t3)
        x3 = field.mod(x3 - t0)
        z3 = field.mod(t2 * t1)
        z3 = field.mod(z3 + z3)
        z3 = field.mod(z3 + z3)
        ProjectivePoint.new(point.group, x3, y3, z3)
      end
    end
  end
end
