require 'spec_helper'
require 'openssl'
require 'base64'

RSpec.describe SpreeCmCommissioner::RsaService do

  let(:key_pair) { OpenSSL::PKey::RSA.new(2048) }
  let(:private_key) { key_pair.to_pem }
  let(:public_key) { key_pair.public_key.to_pem }
  let(:data) { "Hello, BookMe+" }

  describe '#sign' do
    context 'when private key is provided' do
      it 'returns signed data with signature' do
        service = described_class.new(private_key: private_key)
        signed_data = service.sign(data)

        original_data, encoded_signature = signed_data.split('.')
        expect(original_data).to eq(data)
        expect(encoded_signature).not_to be_nil
      end
    end

    context 'when private key is missing' do
      it 'raises an error' do
        service = described_class.new
        expect { service.sign(data) }.to raise_error('Private key is required to sign data')
      end
    end
  end

  describe '#verify' do
    context 'when public key is provided' do
      it 'verifies a valid signature successfully' do
        signer = described_class.new(private_key: private_key)
        verifier = described_class.new(public_key: public_key)

        signed_data = signer.sign(data)
        original_data, encoded_signature = signed_data.split('.')
        result = verifier.verify(original_data, encoded_signature)

        expect(result).to be true
      end

      it 'fails verification for modified data' do
        signer = described_class.new(private_key: private_key)
        verifier = described_class.new(public_key: public_key)

        signed_data = signer.sign(data)
        _original_data, encoded_signature = signed_data.split('.')
        tampered_data = "Hacked!"

        result = verifier.verify(tampered_data, encoded_signature)

        expect(result).to be false
      end
    end

    context 'when public key is missing' do
      it 'raises an error' do
        service = described_class.new
        expect { service.verify(data, 'signature') }.to raise_error('Public key is required to verify signature')
      end
    end
  end
end
