# frozen_string_literal: true

require "spec_helper"
require "securerandom"

RSpec.describe ECDSA::Ext::ProjectivePoint do
  describe "#from_affine/to_affine" do
    it do
      groups.each do |group|
        gen = described_class.from_affine(group.generator)
        expect(gen.to_affine).to eq(group.generator)
        private_key = SecureRandom.random_number(group.order - 1)
        p = group.generator * private_key
        pp = described_class.from_affine(p)
        expect(pp.to_affine).to eq(p)
      end
    end
  end

  describe "infinity point" do
    it do
      groups.each do |group|
        i = described_class.infinity(group)
        expect(i.infinity?).to be true
        gen = described_class.from_affine(group.generator)
        expect(i + gen).to eq(gen)
        expect(gen + i).to eq(gen)
      end
    end
  end

  describe "#multiply_by_scalar" do
    it do
      groups.each do |group|
        private_key = SecureRandom.random_number(group.order - 1)
        p = group.generator * private_key
        pp_gen = described_class.from_affine(group.generator)
        pp = pp_gen * private_key
        expect(pp.to_affine).to eq(p)
      end
    end
  end

  describe "repeat addition" do
    it do
      groups.each do |group|
        fixture_file = "#{group.name}.json"
        if exist_fixture?(fixture_file)
          gen = described_class.from_affine(group.generator)
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
          pp_gen = described_class.from_affine(group.generator)
          private_key1 = SecureRandom.random_number(group.order - 1)
          private_key2 = SecureRandom.random_number(group.order - 1)
          p1 = group.generator * private_key1
          p2 = group.generator * private_key2
          pp1 = pp_gen * private_key1
          pp2 = pp_gen * private_key2
          expect((pp1 + pp2).to_affine).to eq(p1 + p2)
        end
      end
    end
  end

  describe "#double" do
    it do
      groups.each do |group|
        fixture_file = "#{group.name}.json"
        gen = described_class.from_affine(group.generator)
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
end
