# frozen_string_literal: true

require "ecdsa_ext"
require "json"
require "securerandom"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def groups
  ECDSA::Group::NAMES.map { |name| Module.const_get("ECDSA::Group::#{name}") }
  # [ECDSA::Group::Secp256k1]
end

def load_fixture(file_name)
  File.read(File.join(File.dirname(__FILE__), "fixtures", file_name))
end

def exist_fixture?(file_name)
  File.exist?(File.join(File.dirname(__FILE__), "fixtures", file_name))
end
