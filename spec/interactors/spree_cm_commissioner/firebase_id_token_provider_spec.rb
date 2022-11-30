require 'spec_helper'

RSpec.describe SpreeCmCommissioner::FirebaseIdTokenProvider do
  let(:id_token) {"eyJhbGciOiJSUzI1NiIsImtpZCI6Im....YQ9PBRrFvSvkzvlHb0lIgAqg"}
  let(:claim) do 
    {
      "iss"=> "https://securetoken.google.com/vtenh-46ed3",
      "aud"=> "vtenh-46ed3",
      "auth_time"=> 1646117677,
      "user_id"=> "C3O4jmfZsAYQn9vJxDZZFNhmETj2",
      "sub"=> "C3O4jmfZsAYQn9vJxDZZFNhmETj2",
      "iat"=> 1646117677,
      "exp"=> 1646121277,
      "firebase"=> {
        "identities"=> {
          "apple.com"=> [
            "000561.52d801e34d58420a9bbc75d3f13f8a91.1143"
          ]
        },
        "sign_in_provider"=> "apple.com"
      }
    }
  end

  let(:cert) do 
    {
      "cf5d8e74f3c486ee503d5eec93a101c64bacf7da" => "-----BEGIN CERTIFICATE-----\nMIIDHTCCAgWgAwIBAgIJALoLj0iyX/vlMA0GCSqGSIb3DQEBBQUAMDExLzAtBgNV\nBAMMJnNlY3\n-----END CERTIFICATE-----",
      "9962f04feed9545ce2134ab54ceef581af24baff" => "-----BEGIN CERTIFICATE-----\nMIIDHDCCAgSgAwIBAgIIF3yfllsxk6owDQYJKoZIhvcNAQEFBQAwMTEvMC0GA1UE\nAwwmc2VjdXJ\n-----END CERTIFICATE-----"
    }
  end

  describe '.decode_id_token' do
    it 'success decoded and return provider info' do
      kid = 'cf5d8e74f3c486ee503d5eec93a101c64bacf7da'
      subject = SpreeCmCommissioner::FirebaseIdTokenProvider.new(id_token: id_token)
   
      allow(subject).to receive(:cert_generation).and_return(cert[kid])
      allow(subject).to receive(:decode_id_token).and_return(claim)

      response = subject.decode_id_token

      expect(response['iss']).to eq(claim['iss'])
      expect(response['aud']).to eq(claim['aud'])
      expect(response['firebase']['identities']).to eq(claim['firebase']['identities'])
    end

    it 'wrong id token return error' do
      subject = SpreeCmCommissioner::FirebaseIdTokenProvider.new(id_token: 'fake token')

      expect{subject.decode_id_token}.to raise_error(Interactor::Failure)
    end

    it 'wrong kid return error' do
      kid = 'fake74f3c486ee503d5eec93a101c64bacf7da'
      subject = SpreeCmCommissioner::FirebaseIdTokenProvider.new(id_token: id_token)
      allow(subject).to receive(:kid).and_return(kid)

      expect{subject.decode_id_token}.to raise_error(Interactor::Failure)
    end
  end

  describe '.cert_generation' do
    it 'return success when kid matched' do
      kid = 'cf5d8e74f3c486ee503d5eec93a101c64bacf7da'
      
      subject = SpreeCmCommissioner::FirebaseIdTokenProvider.new(id_token: id_token)
      allow(subject).to receive(:fetch_cert_key).and_return(cert)
      response = subject.cert_generation(kid)

      expect(response).to match(cert[kid])
    end

    it 'return fails when kid not match' do 
      kid = 'fake_kid'
      subject = SpreeCmCommissioner::FirebaseIdTokenProvider.new(id_token: id_token)
      cert = subject.cert_generation(kid)

      expect(cert).to eq(nil)
    end
  end

  describe '.call' do
    it 'success return the provider object' do
      subject = SpreeCmCommissioner::FirebaseIdTokenProvider.new(id_token: id_token)
      allow(subject).to receive(:decode_id_token).and_return(claim)

      response = subject.call

      provider_name = claim['firebase']['sign_in_provider'].split(".").first
      provider_sub = claim['firebase']['identities']['apple.com'].first
      
      expect(response[:provider_name]).to match(provider_name)
      expect(response[:sub]).to match(provider_sub)
    end

    it 'fail when id_token not valid return the error message' do
      id_token = 'fake_id_token'
      subject = SpreeCmCommissioner::FirebaseIdTokenProvider.new(id_token: id_token)

      expect{subject.call}.to raise_error(Interactor::Failure)
    end
  end
end
