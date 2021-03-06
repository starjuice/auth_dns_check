require "auth_dns_check"

RSpec.describe AuthDnsCheck::Client do
  context "pending" do
    it "supports records of types other than A"
    it "supports IPv6"
  end

  describe "all?(fqdn)" do
    context "by default" do
      subject { described_class.new(default: Resolv::DNS.new(nameserver: ENV.fetch("DEFAULT_RESOLVER"))) }

      it "is true if all authoritatives answer for fqdn" do
        expect(subject.all?("same.internal.domain")).to be true
      end

      it "is false if two or more authoritatives disagree for fqdn" do
        expect(subject.all?("different.internal.domain")).to be false
      end

      it "is false if no authoritatives answer for fqdn" do
        expect(subject.all?("missing.internal.domain")).to be false
      end

      it "raises an Error if no authoritatives can be found" do
        expect {
          subject.all?("nonexistent.domain")
        }.to raise_error(AuthDnsCheck::Error, "no name servers found for nonexistent.domain")
      end

      it "ignores ordering of answers" do
        expect(subject.all?("multi-same.internal.domain")).to be true
      end

      context "specifying record type" do

        it "is true if all authoritatives answer for fqdn" do
          expect(subject.all?("mixed-same.internal.domain", types: ["A"])).to be true
        end

        it "is false if two or more authoritatives disagree for fqdn" do
          expect(subject.all?("mixed-different.internal.domain", types: ["TXT"])).to be false
        end

        it "is false if no authoritatives answer for fqdn" do
          expect(subject.all?("mixed-different.internal.domain", types: ["NS"])).to be false
        end

      end
    end

    context "when overriding a domain" do
      let(:domain) { "example.com" }
      let(:fqdn) { "host.#{domain}" }
      let(:auth1) { double(Resolv::DNS) }
      let(:auth2) { double(Resolv::DNS) }
      let(:overrides) { { domain => [ auth1, auth2 ] } }

      subject { described_class.new(overrides: overrides) }

      context "with default" do
        let(:auth3) { double(Resolv::DNS) }
        let(:auth4) { double(Resolv::DNS) }
        let(:overrides) { { domain => [ auth1, auth2 ], default: [ auth3, auth4 ] } }

        it "queries domain overrides for the domain" do
          expect(auth1).to receive(:getresources).with(fqdn, IN::A).and_return([ip("127.0.0.1")])
          expect(auth2).to receive(:getresources).with(fqdn, IN::A).and_return([ip("127.0.0.1")])
          expect(auth3).to_not receive(:getresources)
          expect(auth4).to_not receive(:getresources)
          subject.all?(fqdn)
        end

        it "queries default overrides for others" do
          expect(auth1).to_not receive(:getresources)
          expect(auth2).to_not receive(:getresources)
          expect(auth3).to receive(:getresources).with("some.other-domain.com", IN::A).and_return([ip("127.0.0.1")])
          expect(auth4).to receive(:getresources).with("some.other-domain.com", IN::A).and_return([ip("127.0.0.1")])
          subject.all?("some.other-domain.com")
        end

      end

      it "is true if all overrides answer for fqdn" do
        expect(auth1).to receive(:getresources).with(fqdn, IN::A).and_return([ip("127.0.0.1")])
        expect(auth2).to receive(:getresources).with(fqdn, IN::A).and_return([ip("127.0.0.1")])
        expect(subject.all?(fqdn)).to be true
      end

      it "is false if two or more overrides disagree for fqdn" do
        expect(auth1).to receive(:getresources).with(fqdn, IN::A).and_return([ip("127.0.0.1")])
        expect(auth2).to receive(:getresources).with(fqdn, IN::A).and_return([ip("127.0.0.2")])
        expect(subject.all?(fqdn)).to be false
      end

      it "is false if no overrides answer for fqdn" do
        expect(auth1).to receive(:getresources).with(fqdn, IN::A).and_return([])
        expect(auth2).to receive(:getresources).with(fqdn, IN::A).and_return([])
        expect(subject.all?(fqdn)).to be false
      end

      it "ignores ordering of answers" do
        expect(auth1).to receive(:getresources).with(fqdn, IN::A).and_return([ip("127.0.0.1"), ip("127.0.0.2")])
        expect(auth2).to receive(:getresources).with(fqdn, IN::A).and_return([ip("127.0.0.2"), ip("127.0.0.1")])
        expect(subject.all?(fqdn)).to be true
      end
    end
  end

  describe "has_ip?(fqdn, ip)" do
    subject { described_class.new(default: Resolv::DNS.new(nameserver: ENV.fetch("DEFAULT_RESOLVER"))) }

    it "is true if all authoritatives give ip for fqdn" do
      expect(subject.has_ip?("same.internal.domain", "127.0.0.1")).to be true
    end

    it "is false if two or more authoritatives disagree on ip for fqdn" do
      expect(subject.has_ip?("different.internal.domain", "127.0.0.1")).to be false
    end

    it "is false if no authoritatives give ip for fqdn" do
      expect(subject.has_ip?("missing.internal.domain", "127.0.0.1")).to be false
    end

    it "is false if one or more authoritatives gives any other ip for fqdn" do
      expect(subject.has_ip?("multi-same.internal.domain", "127.0.0.1")).to be false
    end

    it "raises an Error if no authoritatives can be found" do
      expect {
        subject.all?("nonexistent.domain")
      }.to raise_error(AuthDnsCheck::Error, "no name servers found for nonexistent.domain")
    end
  end

  describe "zone finding" do
    subject { described_class.new(default: Resolv::DNS.new(nameserver: ENV.fetch("DEFAULT_RESOLVER"))) }

    it "finds authoritatives when fqdn is the zone" do
      expect(subject.has_ip?("same.internal.domain", "127.0.0.1")).to be true
    end

    it "finds authoritatives when fqdn is a single-component record in the zone" do
      expect(subject.has_ip?("same.internal.domain", "127.0.0.1")).to be true
    end

    it "finds authoritatives when fqdn is a multi-component record in the zone" do
      expect(subject.has_ip?("same.dotted.internal.domain", "127.0.0.1")).to be true
    end

    it "raises an error if no authoritatives can be found" do
      expect {
        subject.all?("nonexistent.domain")
      }.to raise_error(AuthDnsCheck::Error, "no name servers found for nonexistent.domain")
    end
  end

  module IN
    include Resolv::DNS::Resource::IN
  end

  def ip(s)
    Resolv::IPv4.create(s)
  end
end
