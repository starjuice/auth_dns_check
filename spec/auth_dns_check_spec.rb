require "auth_dns_check"

RSpec.describe AuthDnsCheck do

  it "has a version number" do
    expect(described_class::VERSION).not_to be nil
  end

  describe ".client" do

    it "is deprecated" do
      pending "pending removal"
      expect { described_class.client }.to raise(NoMethodError)
    end

    it "returns a Client" do
      expect(described_class.client).to be_a(described_class::Client)
    end

    it "passes overrides to Client.new" do
      overrides = {default: [Resolv::DNS.new(nameserver: "1.1.1.1")]}
      expect(described_class.client(overrides: overrides).overrides).to eql overrides
    end

    it "passes default to Client.new" do
      default = Resolv::DNS.new(nameserver: "8.8.8.8")
      expect(described_class.client(default: default).default).to match_resolver default
    end

    it "matches Client's default overrides" do
      expect(described_class.client.overrides).to eql described_class::Client.new.overrides
    end

    it "matches Client's default default" do
      expect(described_class.client.default).to match_resolver described_class::Client.new.default
    end

  end

  RSpec::Matchers.define :match_resolver do |expected|
    match do |actual|
      actual.is_a?(Resolv::DNS) and expected.is_a?(Resolv::DNS) and
        actual.instance_variable_get(:@config).instance_variable_get(:@config_info) ==
        expected.instance_variable_get(:@config).instance_variable_get(:@config_info)
    end
  end
end
