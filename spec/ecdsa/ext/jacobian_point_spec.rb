# frozen_string_literal: true
require "spec_helper"

RSpec.describe ECDSA::Ext::JacobianPoint do
  describe "#from_affine/to_affine" do
    it do
      groups.each do |group|
        gen = group.generator.to_jacobian
        expect(gen.to_affine).to eq(group.generator)
        x = SecureRandom.random_number(group.order - 1)
        p = group.generator * x
        pp = gen * x
        expect(pp.to_affine).to eq(p)
        expect(pp).to eq(p.to_jacobian)
        expect(described_class.from_affine(group.infinity).infinity?).to be true
      end
    end
  end

  describe "#dobule" do
    it do
      groups.each do |group|
        gen = group.generator.to_jacobian
        expect(gen.double.to_affine).to eq(group.generator.double)
      end
    end
  end

  describe "#add_to_point" do
    it do
      groups.each do |group|
        a = SecureRandom.random_number(group.order - 1)
        b = SecureRandom.random_number(group.order - 1)
        p1 = (group.generator * a).to_jacobian
        p2 = (group.generator * b).to_jacobian
        p3 = (group.generator * (a + b)).to_jacobian
        expect(p1 + p2).to eq(p3)
      end
    end

    context "with negation point" do
      it do
        groups.each do |group|
          x = SecureRandom.random_number(group.order - 1)
          e = SecureRandom.random_number(group.order - 1)
          s = (x * e) % group.order
          xg = group.generator.to_jacobian * x
          sg = group.generator.to_jacobian * s
          n_xeg = xg * (group.order - e)
          expect((sg + n_xeg).to_affine.infinity?).to be true
          expect((sg + n_xeg).infinity?).to be true
        end
      end
    end
  end

  describe "add same point" do
    it do
      groups.each do |group|
        x = SecureRandom.random_number(group.order - 1)
        p1 = group.generator.to_jacobian * x
        p2 = group.generator.to_jacobian * x
        expect(p1 + p2).to eq(p1.double)
      end
    end
  end

  describe "#negate" do
    it do
      groups.each do |group|
        x = SecureRandom.random_number(group.order - 1)
        p = group.generator.to_jacobian * x
        pn = p.negate
        expect((p + pn).infinity?).to be true
        pa = p.to_affine
        expect(pn.to_affine).to eq(pa.negate)
      end
    end
  end

  describe "#== with infinity point" do
    it do
      groups.each do |group|
        p = group.generator.to_jacobian
        infinity = described_class.infinity_point(group)
        expect(infinity == p).to be false
        expect(p == infinity).to be false
        expect(infinity == described_class.infinity_point(group)).to be true
      end
    end
  end

  describe "#== with different group" do
    it do
      k1 = ECDSA::Group::Secp256k1
      r1 = ECDSA::Group::Secp256r1
      p1 = described_class.new(k1, 1, 2, 1)
      p2 = described_class.new(r1, 1, 2, 1)
      expect(p1 == p2).to be false
      inf1 = described_class.infinity_point(k1)
      inf2 = described_class.infinity_point(r1)
      expect(inf1 == inf2).to be false
      expect(inf1 == described_class.infinity_point(k1)).to be true
    end
  end

  describe "#eql? and #hash" do
    it "is consistent with #== for different representations" do
      groups.each do |group|
        x = 1 + SecureRandom.random_number(group.order - 1)
        gen = group.generator.to_jacobian
        p1 = gen * x
        p2 = (group.generator * x).to_jacobian
        p3 = (gen * (x + 1)) + gen.negate
        expect(p1.coords).not_to eq(p3.coords)
        expect(p1).to eql(p2)
        expect(p1).to eql(p3)
        expect(p1.hash).to eq(p2.hash)
        expect(p1.hash).to eq(p3.hash)
      end
    end

    it "works as a Hash key" do
      groups.each do |group|
        x = 1 + SecureRandom.random_number(group.order - 1)
        gen = group.generator.to_jacobian
        p1 = gen * x
        p2 = (group.generator * x).to_jacobian
        p3 = (gen * (x + 1)) + gen.negate
        expect([p1, p2, p3].uniq.size).to eq(1)
        expect({ p1 => :found }[p3]).to eq(:found)
        expect(p1.hash).not_to eq(p1.double.hash)
      end
    end

    it "handles infinity points" do
      groups.each do |group|
        inf1 = described_class.infinity_point(group)
        inf2 = described_class.infinity_point(group)
        expect(inf1).to eql(inf2)
        expect(inf1.hash).to eq(inf2.hash)
        expect(inf1).not_to eql(group.generator.to_jacobian)
      end
    end
  end

  describe "#multiply_by_scalar with boundary scalars" do
    it do
      groups.each do |group|
        gen = group.generator.to_jacobian
        bits = group.order.bit_length
        scalars = [
          0,
          1,
          2,
          group.order - 1,
          group.order,
          group.order + 1,
          2 * group.order,
          (1 << bits) - 1,
          1 << bits,
          (1 << (bits + 1)) - 1
        ]
        scalars.each do |k|
          expected = group.generator * k
          actual = gen * k
          expect(actual.to_affine).to eq(expected), "scalar #{k}"
          expect(actual).to eq(expected.to_jacobian)
        end
      end
    end
  end
end
