module AuthDnsCheck

  # Client for performing authoritative DNS checks
  #
  # @todo IPv6 not supported
  class Client

    # authoritative name server overrides
    attr_reader :overrides

    # default resolver for finding authoritative name servers
    attr_reader :default

    # Initialize a new Client
    #
    # @param overrides [Hash<String,Array<Resolv::DNS>>] authoritative name server overrides.
    #   Maps domain names to lists of name servers that should override those published for the domain.
    #   The special domain name {Symbol} +:default+ may list the name servers that should override any other domain.
    # @param default [Resolv::DNS] default resolver for finding authoritative name servers.
    #   Note that this is not the same as +overrides[:default]+.
    def initialize(overrides: {}, default: Resolv::DNS.new("/etc/resolv.conf"))
      @overrides = overrides
      @default = default
    end

    # Check authoritative agreement for a name
    #
    # @param fqdn [String] the name to check
    # @return [Boolean] whether all authoritative agree that +fqdn+ has the same non-empty set of records
    # @raise [Error] if authoritative name servers could not be found
    # @todo Records of types other than A not yet supported
    def all?(fqdn)
      answers = get_addresses(fqdn)
      answers.all? { |x| x.any? and x == answers.first }
    end

    # Check authoritative agreement for the specific address for a name
    #
    # @param fqdn [String] the name to check
    # @param ip [String] the expected address
    # @return [Boolean] whether all authoritative name servers agree that the only address of +name+ is +ip+
    # @raise [Error] if authoritative name servers could not be found
    def has_ip?(fqdn, ip)
      answers = get_addresses(fqdn)
      answers.all? do |x|
        x.any? and x.all? { |i| i == ip }
      end
    end

    private

    def get_addresses(fqdn)
      get_authoritatives(fqdn).
        map { |x| x.getaddresses(fqdn) }.
        map { |x| x.collect(&:to_s).sort }
    end

    def get_authoritatives(fqdn)
      find_zone(fqdn) { |zone| overridden_authoritatives_for(zone) } or
        overridden_authoritatives_for(:default) or
        find_zone(fqdn) { |zone| default_authoritatives_for(zone) } or
        raise Error.new("no name servers found for #{fqdn}")
    end

    def find_zone(fqdn)
      zone = fqdn
      while zone
        auths = yield(zone)
        if auths and auths.any?
          break auths
        else
          _, zone = zone.split(".", 2)
        end
      end
    end

    def authoritatives_for(zone)
      overridden_authoritatives_for(zone) || overridden_authoritatives_for(:default) || default_authoritatives_for(zone)
    end

    def overridden_authoritatives_for(zone)
      @overrides[zone]
    end

    def default_authoritatives_for(zone)
      @default.
        getresources(zone, Resolv::DNS::Resource::IN::NS).
        map(&:name).
        map(&:to_s).
        map { |x| @default.getaddresses(x) }.
        flatten.
        map(&:to_s).
        uniq.
        map { |x| Resolv::DNS.new(nameserver: x) }
    end

  end

end
