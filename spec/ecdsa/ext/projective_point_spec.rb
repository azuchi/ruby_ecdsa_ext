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
  end
end
