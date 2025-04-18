require 'spec_helper'

RSpec.describe SpreeCmCommissioner::AesEncryptionService do
  let(:key) { OpenSSL::Random.random_bytes(32) }
  let(:plaintext) { 'Secret Message for BookMe+' }

  describe '.encrypt' do
    it 'returns a base64 encoded encrypted string' do
      encrypted = described_class.encrypt(plaintext, key)
      expect(encrypted).to be_a(String)
      expect(Base64.decode64(encrypted).length).to be > plaintext.length
    end
  end

  describe '.decrypt' do
    context 'with valid encrypted text and key' do
      it 'decrypts back to the original plaintext' do
        encrypted = described_class.encrypt(plaintext, key)
        decrypted = described_class.decrypt(encrypted, key)

        expect(decrypted).to eq(plaintext)
      end
    end

    context 'with a wrong key' do
      it 'raises a decryption error' do
        encrypted = described_class.encrypt(plaintext, key)
        wrong_key = OpenSSL::Random.random_bytes(32)

        expect {
          described_class.decrypt(encrypted, wrong_key)
        }.to raise_error(RuntimeError, /Decryption failed/)
      end
    end

    context 'with tampered encrypted text' do
      it 'raises a decryption error' do
        encrypted = described_class.encrypt(plaintext, key)
        tampered = Base64.decode64(encrypted)
        tampered[20] = (tampered[20].ord ^ 0x01).chr
        corrupted = Base64.encode64(tampered)

        expect {
          described_class.decrypt(corrupted, key)
        }.to raise_error(RuntimeError, /Decryption failed/)
      end
    end
  end
end
