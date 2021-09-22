require 'spec_helper'

describe EncryptAttributes::Encrypt::AES do
  let(:password) { 'password' }
  let(:plaintext) { 'data' }
  let(:legacy_ciphertext) { "U2FsdGVkX19hYmNkZWZnaNP1CILqdQwlmuFn9x/Yr9s=\n" }
  let(:v1_ciphertext) do
    "v1|ewxF/7WsWo1mG+iQTF1o7f+mFoa6topAm8x76rD6jzLLrJ4pNuqAw42yBtLF\nKSPTH9AvohkJoRiX68fuY+XWzw==\n"
  end

  subject { EncryptAttributes::Encrypt::AES.new(password) }

  describe '#encrypt' do
    it 'returns different values each time (due to random IV and salt)' do
      expect(subject.encrypt(plaintext)).to_not eq subject.encrypt(plaintext)
    end

    it 'prepends "v1|"' do
      expect(subject.encrypt(plaintext)).to start_with 'v1|'
    end

    it 'generates decryptable ciphertexts' do
      ciphertext = subject.encrypt(plaintext)
      expect(subject.decrypt(ciphertext)).to eq plaintext
    end
  end

  describe '#decrypt' do
    it(
      'decrypts legacy ciphertexts (only on Ruby 2.7)',
      skip: ('Unsupported on Ruby 3' if RUBY_VERSION.to_f >= 3.0)
    ) do
      expect(subject.decrypt(legacy_ciphertext)).to eq plaintext
    end

    it 'decrypts v1 ciphertexts' do
      expect(subject.decrypt(v1_ciphertext)).to eq plaintext
    end

    it 'returns nil for empty ciphertexts' do
      expect(subject.decrypt('')).to eq nil
    end
  end
end
