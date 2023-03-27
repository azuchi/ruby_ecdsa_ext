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
end
