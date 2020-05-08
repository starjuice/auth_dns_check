module AuthDnsCheck

  class Client

    def initialize(overrides: {}, default: Resolv::DNS.new)
      @overrides = overrides
      @default = default
    end

    def all?(fqdn)
      answers = authoritatives_for(fqdn).
        map { |x| x.getaddresses(fqdn) }.
        map { |x| x.collect(&:to_s).sort }
      answers.all? { |x| x.any? and x == answers.first }
    end

    private

    def authoritatives_for(fqdn)
      zone = fqdn.gsub(/\A[^.]+\./, '')
      overridden_authoritatives_for(zone) || default_authoritatives_for(zone)
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
