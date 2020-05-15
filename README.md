[![Gem](https://img.shields.io/gem/v/auth_dns_check.svg?style=flat)](https://rubygems.org/gems/auth_dns_check "View this project in Rubygems")

# AuthDnsCheck

Provides a client for checking that all authoritative DNS servers know
about a record and agree on its value(s).

Supports global or per-zone overrides for the set of authoritative DNS
servers, for bypassing AnyCast arrangements.

Does not yet support records other than A records.

Does not yet support IPv6.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'auth_dns_check'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install auth_dns_check

## Documentation

Full API documentation is available on [rubydoc.info](https://www.rubydoc.info/gems/auth_dns_check).

## Usage

Example:

```
require "auth_dns_check"

# Check that the authoritative name servers for peculiardomain.com
# agree that changed.peculiardomain.com has the address 192.168.1.1
# and no other addresses.
#
client = AuthDnsCheck::Client.new
client.has_ip?("changed.peculiardomain.com", "192.168.1.1")

# Ignore the NS records for peculiardomain.com and check that
# 192.168.0.253 and 192.168.0.252 both know about and agree on
# any and all records for newhost.peculiardomain.com.
#
client = AuthDnsCheck::Client.new(
  overrides: {
    :default => [
      Resolv::DNS.new(nameserver: "192.168.0.253"),
      Resolv::DNS.new(nameserver: "192.168.0.252"),
    ]
  }
)
client.all?("newhost.peculiardomain.com")
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

Note that `rake spec` does not work. The tests rely on a pair of name servers configured with fixtures.

To run the tests:

```
docker-compose down --volumes --remove-orphans && \
  docker-compose build test && \
  docker-compose run test
```

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/starjuice/auth_dns_check.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
