require 'spec_helper'

describe EncryptAttributes::Encrypt::AES do
  let(:password) { "password" }
  let(:data) { "data" }
  let(:encrypted_data) { "U2FsdGVkX19hYmNkZWZnaE67bR8AgXL/LM+fnAQ/GVg=\n" }

  subject { EncryptAttributes::Encrypt::AES.new(password) }

  describe "#encrypt" do
    before do
      allow(subject).to receive(:generate_salt) { "abcdefgh" }
    end

    it { expect(subject.encrypt(data)).to eq encrypted_data }
  end

  describe "#decrypt" do
    it { expect(subject.decrypt(encrypted_data)).to eq data }
  end
end
