## [Unreleased]

## [0.5.2] - 2026-08-07

- Fix a timing leak of the ephemeral key's bit length in `ECDSA.sign` by padding the scalar with the group order
- Check r and s against the range [1, n-1] (group order) instead of the curve's prime field in `ECDSA.check_signature!`
- Fix `NoMethodError` when comparing an infinity point with a non-infinity point via `==`

## [0.1.0] - 2023-02-23

- Initial release
