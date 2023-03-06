# Extension of the ecdsa gem

This library is an extension of the [ecdsa gem](https://github.com/DavidEGrayson/ruby_ecdsa/),
which mainly speeds up the computation of points on elliptic curves by using projective rather than affine coordinates.

This gem was not written by a cryptography expert and has not been carefully checked as with the original gem.
It is provided "as is" and it is the user's responsibility to make sure it will be suitable for the desired purpose.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ecdsa_ext'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install ecdsa_ext

## Usage

### Convert coordinate from affine to projective

```ruby
require 'ecdsa_ext'
require 'securerandom'

group = ECDSA::Group::Secp256k1
private_key = 1 + SecureRandom.random_number(group.order - 1)
affine_point = group.generator * private_key
#<ECDSA::Point: secp256k1, 0x22a7d03cd6fec52e13d2713da6921cf8f374631ecea7d575d31c3f338a410ad, 0x530b82285b951582bc330fc0b1d26df56bf93277d1229676ab9c2d4749098a7c>

# convert to projective point
projective_point = affine_point.to_projective
#<ECDSA::Ext::ProjectivePoint:0x00007f45baa7f5b0 @group=#<ECDSA::Group:secp256k1>, @x=979696094695476041658010915065787178569931130816884020506645009594358960301, @y=37562300065191370074864991137132392549749230653372621152572375247509483260540, @z=1>
```

### Create directory

```ruby
require 'ecdsa_ext'
require 'securerandom'

group = ECDSA::Group::Secp256k1
private_key = 1 + SecureRandom.random_number(group.order - 1)
projective_point = group.generator.to_projective * private_key
#<ECDSA::Ext::ProjectivePoint:0x00007f45baa7f5b0 @group=#<ECDSA::Group:secp256k1>, @x=979696094695476041658010915065787178569931130816884020506645009594358960301, @y=37562300065191370074864991137132392549749230653372621152572375247509483260540, @z=1>
```

### Operation

`ECDSA::Ext::ProjectivePoint` instance supports point addition, scalar multiplication and negation.

```ruby
require 'ecdsa_ext'

# addition
projective_point3 = projective_point1 + projective_point2

# multiplication
projective_point4 = projective_point3 * 123

# negation
projective_point4_neg = projective_point4.negate
```

### Convert coordinate from projective to affine

```ruby
require 'ecdsa_ext'

affine_point = projective_point4.to_affine
```

### Use jacobian coordinates

Jacobian coordinates have been supported since 0.3.0.

When using Jacobian coordinates, use `ECDSA::Ext::JacobianPoint` instead of `ECDSA::Ext::ProjectivePoint`.
In addition, `ECDSA::Point` now has a `to_jacobian` method that convert affine coordinates to jacobian coordinates.