require "resolv"

require "auth_dns_check/client"
require "auth_dns_check/version"

# Parent module for the authoritative DNS check library
#
# @see Client
module AuthDnsCheck
  # Any AuthDnsCheck error
  #
  # Currently the only error is a failure to find authoritative name servers on the network.
  class Error < StandardError; end

  # Returns a new {Client}
  #
  # @deprecated See {Client}
  def self.client(overrides: {}, default: Resolv::DNS.new("/etc/resolv.conf"))
    Client.new(overrides: overrides, default: default)
  end

end
