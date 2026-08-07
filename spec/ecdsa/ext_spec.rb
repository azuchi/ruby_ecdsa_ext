# frozen_string_literal: true
require "spec_helper"
require "ecdsa/ext/sign_verify"
RSpec.describe ECDSA::Ext do
  describe "sign and verify" do
    it do
      groups.each do |group|
        private_key = 1 + SecureRandom.random_number(group.order - 1)
        temporary_key = 1 + SecureRandom.random_number(group.order - 1)
        digest = "digest"
        signature = ECDSA.sign(group, private_key, digest, temporary_key)
        public_key = group.generator.to_jacobian * private_key
        expect(
          ECDSA.valid_signature?(public_key.to_affine, digest, signature)
        ).to be true
      end
    end
  end

  describe "sign with short temporary key" do
    it "generates same signature as affine computation" do
      group = ECDSA::Group::Secp256k1
      private_key = 1 + SecureRandom.random_number(group.order - 1)
      temporary_key = 0xffff # short bit length to exercise scalar padding
      digest = "digest"
      signature = ECDSA.sign(group, private_key, digest, temporary_key)
      field = ECDSA::PrimeField.new(group.order)
      expected_r = field.mod(group.generator.multiply_by_scalar(temporary_key).x)
      e = ECDSA.normalize_digest(digest, group.bit_length)
      expected_s =
        field.mod(field.inverse(temporary_key) * (e + expected_r * private_key))
      expect(signature.r).to eq(expected_r)
      expect(signature.s).to eq(expected_s)
    end
  end

  describe "check_signature!" do
    it "rejects r and s outside [1, n-1]" do
      group = ECDSA::Group::Secp256k1 # prime field is larger than the order
      private_key = 1 + SecureRandom.random_number(group.order - 1)
      temporary_key = 1 + SecureRandom.random_number(group.order - 1)
      digest = "digest"
      signature = ECDSA.sign(group, private_key, digest, temporary_key)
      public_key = (group.generator.to_jacobian * private_key).to_affine
      bad_r = ECDSA::Signature.new(group.order, signature.s)
      expect { ECDSA.check_signature!(public_key, digest, bad_r) }.to raise_error(
        ECDSA::InvalidSignatureError
      )
      bad_s = ECDSA::Signature.new(signature.r, group.order)
      expect { ECDSA.check_signature!(public_key, digest, bad_s) }.to raise_error(
        ECDSA::InvalidSignatureError
      )
    end
  end
end
