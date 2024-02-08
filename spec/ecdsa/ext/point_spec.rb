# frozen_string_literal: true
require "spec_helper"

RSpec.describe ECDSA::Point do
  describe "#to_hex" do
    it do
      p =
        described_class.new(
          ECDSA::Group::Secp256k1,
          0xdca2465c2d419604c0c1245706b443b19f58f6cfb75ebf39452fd69c8a826cf3,
          0xa62eba1eb074c3e2e139f8ccafa554738e12a69aae73c3c8b23ed94a7642e9e2
        )
      expect(p.to_hex).to eq(
        "02dca2465c2d419604c0c1245706b443b19f58f6cfb75ebf39452fd69c8a826cf3"
      )
      expect(p.to_hex(false)).to eq(
        "04dca2465c2d419604c0c1245706b443b19f58f6cfb75ebf39452fd69c8a826cf3a62eba1eb074c3e2e139f8ccafa554738e12a69aae73c3c8b23ed94a7642e9e2" # rubocop:disable all
      )
    end
  end
end
