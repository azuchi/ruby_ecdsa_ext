# frozen_string_literal: true

require_relative "../lib/ecdsa_ext"
require "benchmark/ips"
require "securerandom"

Benchmark.ips do |x|
  x.config(time: 60, warmup: 10)

  group = ECDSA::Group::Secp256k1

  x.report("multi for affine") do
    x = SecureRandom.random_number(group.order - 1)
    group.generator * x
  end
  x.report("multi for projective") do
    x = SecureRandom.random_number(group.order - 1)
    group.generator.to_projective * x
  end
  x.report("multi for jacobian") do
    x = SecureRandom.random_number(group.order - 1)
    group.generator.to_jacobian * x
  end
end
