# frozen_string_literal: true

require "spec_helper"

RSpec.describe ECDSA::Ext::ProjectivePoint do
  describe "#from_affine/to_affine" do
    it do
      groups.each do |group|
        gen = group.generator.to_projective
        x = SecureRandom.random_number(group.order - 1)
        p = group.generator * x
        pp = gen * x
        expect(pp.to_affine).to eq(p)
        expect(described_class.from_affine(group.infinity).infinity?).to be true
      end
    end
  end

  describe "infinity point" do
    it do
      groups.each do |group|
        i = described_class.infinity_point(group)
        expect(i.infinity?).to be true
        gen = group.generator.to_projective
        expect(i + gen).to eq(gen)
        expect(gen + i).to eq(gen)
      end
    end
  end

  describe "#multiply_by_scalar" do
    it do
      groups.each do |group|
        x = SecureRandom.random_number(group.order - 1)
        p = group.generator * x
        pp_gen = group.generator.to_projective
        pp = pp_gen * x
        expect(pp.to_affine).to eq(p)
      end
    end
  end

  describe "repeat addition" do
    it do
      groups.each do |group|
        fixture_file = "#{group.name}.json"
        if exist_fixture?(fixture_file)
          gen = group.generator.to_projective
          p = gen
          vectors = JSON.parse(load_fixture("#{group.name}.json"))
          vectors.each do |v|
            p_a = p.to_affine
            expect(p_a.x).to eq(v["x"].hex)
            expect(p_a.y).to eq(v["y"].hex)
            p += gen
          end
          p_a = (gen * 20).to_affine
          expect(p_a.x).to eq(vectors.last["x"].hex)
          expect(p_a.y).to eq(vectors.last["y"].hex)
        else
          pp_gen = group.generator.to_projective
          x1 = SecureRandom.random_number(group.order - 1)
          x2 = SecureRandom.random_number(group.order - 1)
          p1 = group.generator * x1
          p2 = group.generator * x2
          pp1 = pp_gen * x1
          pp2 = pp_gen * x2
          expect((pp1 + pp2).to_affine).to eq(p1 + p2)
        end
      end
    end
  end

  describe "#double" do
    it do
      groups.each do |group|
        fixture_file = "#{group.name}.json"
        gen = group.generator.to_projective
        if exist_fixture?(fixture_file)
          p = gen.double
          vectors = JSON.parse(load_fixture("#{group.name}.json"))
          p_a = p.to_affine
          expect(p_a.x).to eq(vectors[1]["x"].hex)
          expect(p_a.y).to eq(vectors[1]["y"].hex)
          p_a = p.double.to_affine
          expect(p_a.x).to eq(vectors[3]["x"].hex)
          expect(p_a.y).to eq(vectors[3]["y"].hex)
        else
          p1 = gen * 4
          p2 = gen.double.double
          expect(p1).to eq(p2)
        end
      end
    end
  end

  describe "#add_to_point" do
    it do
      groups.each do |group|
        a = SecureRandom.random_number(group.order - 1)
        b = SecureRandom.random_number(group.order - 1)
        p1 = (group.generator * a).to_projective
        p2 = (group.generator * b).to_projective
        p3 = (group.generator * (a + b)).to_projective
        expect(p1 + p2).to eq(p3)
      end
    end

    context "with negation point" do
      it do
        groups.each do |group|
          x = SecureRandom.random_number(group.order - 1)
          e = SecureRandom.random_number(group.order - 1)
          s = (x * e) % group.order
          xg = group.generator.to_projective * x
          sg = group.generator.to_projective * s
          n_xeg = xg * (group.order - e)
          expect((sg + n_xeg).to_affine.infinity?).to be true
          expect((sg + n_xeg).infinity?).to be true
        end
      end
    end
  end

  describe "#negate" do
    it do
      groups.each do |group|
        x = SecureRandom.random_number(group.order - 1)
        gen = group.generator.to_projective
        p = gen * x
        expect((p + p.negate).infinity?).to be true
        p_a = p.to_affine
        expect(p.negate.to_affine).to eq(p_a.negate)
      end
    end
  end

  describe "#==" do
    it do
      groups.each do |group|
        x = SecureRandom.random_number(group.order - 1)
        gen = group.generator.to_projective
        p1 = gen * x
        p2 = (group.generator * x).to_projective
        expect(p1).to eq(p2)
        expect(p1.double).not_to eq(p2)
      end
    end

    context "with infinity point" do
      it do
        groups.each do |group|
          p = group.generator.to_projective
          infinity = described_class.infinity_point(group)
          expect(infinity == p).to be false
          expect(p == infinity).to be false
          expect(infinity == described_class.infinity_point(group)).to be true
        end
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
        gen = group.generator.to_projective
        p1 = gen * x
        p2 = (group.generator * x).to_projective
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
        gen = group.generator.to_projective
        p1 = gen * x
        p2 = (group.generator * x).to_projective
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
        expect(inf1).not_to eql(group.generator.to_projective)
      end
    end
  end

  describe "#multiply_by_scalar with boundary scalars" do
    it do
      groups.each do |group|
        gen = group.generator.to_projective
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
          expect(actual).to eq(expected.to_projective)
        end
      end
    end
  end

  describe ".new" do
    it "raises ArgumentError when z is zero" do
      group = ECDSA::Group::Secp256k1
      expect { described_class.new(group, 1, 2, 0) }.to raise_error(
        ArgumentError,
        /z must not be zero/
      )
      expect { described_class.new(group, 1, 2, 1) }.not_to raise_error
      expect(described_class.infinity_point(group).infinity?).to be true
    end
  end
end
