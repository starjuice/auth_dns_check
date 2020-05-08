require "resolv"

require "auth_dns_check/client"
require "auth_dns_check/version"

module AuthDnsCheck
  class Error < StandardError; end

  def self.client(overrides: {}, default: Resolv::DNS.new)
    Client.new(overrides: overrides, default: default)
  end

end
