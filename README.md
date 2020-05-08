# AuthDnsCheck

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/auth_dns_check`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'auth_dns_check'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install auth_dns_check

## Usage

Example:

```
require "auth_dns_check"

client = AuthDnsCheck.client(
  overrides: {
    "peculiardomain.com" => [
      Resolv::DNS.new(nameserver: "192.168.0.253"),
      Resolv::DNS.new(nameserver: "192.168.0.252"),
    ]
  }
)

# Ignore the NS records for peculiardomain.com and check that
# 192.168.0.253 and 192.168.0.252 both know about and agree on
# 4acf8ea915b7.peculiardomain.com.
#
client.all?("4acf8ea915b7.peculiardomain.com")
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/auth_dns_check.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
