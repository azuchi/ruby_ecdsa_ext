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
end
