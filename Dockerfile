FROM ruby:2.6

RUN gem install --no-doc bundler:2.0.1

WORKDIR /usr/src

COPY Gemfile .
COPY auth_dns_check.gemspec .
COPY lib/auth_dns_check/version.rb ./lib/auth_dns_check/version.rb
RUN bundle install --jobs=3 --retry=3
COPY lib ./lib
COPY spec ./spec

CMD bundle exec rspec -fd spec
