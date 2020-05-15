module AuthDnsCheck

  class Client

    def initialize(overrides: {}, default: Resolv::DNS.new)
      @overrides = overrides
      @default = default
    end

    def all?(fqdn)
      answers = get_addresses(fqdn)
      answers.all? { |x| x.any? and x == answers.first }
    end

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
