# frozen_string_literal: true

# A monkey patch to allow signature generation and verification of existing ECDSA with Jacobian coordinates.
module ECDSA
  def self.sign(group, private_key, digest, temporary_key)
    # Second part of step 1: Select ephemeral elliptic curve key pair
    # temporary_key was already selected for us by the caller
    r_point = (group.generator.to_jacobian * temporary_key).to_affine

    # Steps 2 and 3
    point_field = PrimeField.new(group.order)
    r = point_field.mod(r_point.x)
    return nil if r.zero?

    # Step 4, calculating the hash, was already performed by the caller.

    # Step 5
    e = normalize_digest(digest, group.bit_length)

    # Step 6
    s =
      point_field.mod(
        point_field.inverse(temporary_key) * (e + r * private_key)
      )
    return nil if s.zero?

    Signature.new r, s
  end

  def self.check_signature!(public_key, digest, signature)
    group = public_key.group
    field = group.field

    # Step 1: r and s must be in the field and non-zero
    unless field.include?(signature.r)
      raise InvalidSignatureError, "Invalid signature: r is not in the field."
    end
    unless field.include?(signature.s)
      raise InvalidSignatureError, "Invalid signature: s is not in the field."
    end
    if signature.r.zero?
      raise InvalidSignatureError, "Invalid signature: r is zero."
    end
    if signature.s.zero?
      raise InvalidSignatureError, "Invalid signature: s is zero."
    end

    # Step 2 was already performed when the digest of the message was computed.

    # Step 3: Convert octet string to number and take leftmost bits.
    e = normalize_digest(digest, group.bit_length)

    # Step 4
    point_field = PrimeField.new(group.order)
    s_inverted = point_field.inverse(signature.s)
    u1 = point_field.mod(e * s_inverted)
    u2 = point_field.mod(signature.r * s_inverted)

    # Step 5
    r =
      (group.generator.to_jacobian * u1 + public_key.to_jacobian * u2).to_affine
    if r.infinity?
      raise InvalidSignatureError, "Invalid signature: r is infinity in step 5."
    end

    # Steps 6 and 7
    v = point_field.mod r.x

    # Step 8
    if v != signature.r
      raise InvalidSignatureError, "Invalid signature: v does not equal r."
    end

    true
  end
end
