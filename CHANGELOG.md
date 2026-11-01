## [Unreleased]

- Fix `==` of `ProjectivePoint`/`JacobianPoint` to return false for points on different groups
- Add `eql?` and `hash` to `AbstractPoint` so that points can be used as Hash keys consistently with `==`
- Fix the number of iterations in `multiply_by_scalar` to depend only on the bit length of the scalar, and document that signing is still not constant time
- Raise `ArgumentError` in `ECDSA.sign` when `temporary_key` is not in the range [1, n-1]

## [0.5.2] - 2026-08-07

- Fix a timing leak of the ephemeral key's bit length in `ECDSA.sign` by padding the scalar with the group order
- Check r and s against the range [1, n-1] (group order) instead of the curve's prime field in `ECDSA.check_signature!`
- Fix `NoMethodError` when comparing an infinity point with a non-infinity point via `==`

## [0.1.0] - 2023-02-23

- Initial release
