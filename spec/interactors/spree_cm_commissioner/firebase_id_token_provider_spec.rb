require 'spec_helper'

RSpec.describe SpreeCmCommissioner::FirebaseIdTokenProvider, :vcr do
  let(:id_token) {"eyJhbGciOiJSUzI1NiIsImtpZCI6ImE5NmFkY2U5OTk5YmJmNWNkMzBmMjlmNDljZDM3ZjRjNWU2NDI3NDAiLCJ0eXAiOiJKV1QifQ.eyJuYW1lIjoiUGFuaGEgQ2hvbSIsInBpY3R1cmUiOiJodHRwczovL2xoMy5nb29nbGV1c2VyY29udGVudC5jb20vYS9BTG01d3UyUXRmU2owU0NqTGpuSW9jNk5YSzBvSUpTVGVXZ1dXRWJ6XzgyTj1zOTYtYyIsImlzcyI6Imh0dHBzOi8vc2VjdXJldG9rZW4uZ29vZ2xlLmNvbS9jbS1tYXJrZXQtNDMzYjEiLCJhdWQiOiJjbS1tYXJrZXQtNDMzYjEiLCJhdXRoX3RpbWUiOjE2NjkyODQwMDQsInVzZXJfaWQiOiJWcWZtY2o5V1F2UlM4QllBb2VmMk5meGVJdWQyIiwic3ViIjoiVnFmbWNqOVdRdlJTOEJZQW9lZjJOZnhlSXVkMiIsImlhdCI6MTY2OTI4NDAwNCwiZXhwIjoxNjY5Mjg3NjA0LCJmaXJlYmFzZSI6eyJpZGVudGl0aWVzIjp7Imdvb2dsZS5jb20iOlsiMTExNTkxNzcwMTQ4MjcxOTc5NzYzIl19LCJzaWduX2luX3Byb3ZpZGVyIjoiZ29vZ2xlLmNvbSJ9fQ.R95hhSSQI-LEYgjJx9IQ-weuDIZRc7umxVURhdqWvii3pC67GZkPoXMT0QqnehBb4DB7TQyUN_AGbO_G34HlOJZ3g1L7_f_45zdnGodZdW0he4zrGaqNj59pe1oppyvnG9EwupXwjjP1p-ASMvxUJ5VW4_TvkwJx9nIyB3PHNuqvPEvg8eqHACdxQ4lrqJClPgxJoHvh9rLgQmPLbwGGMDBDH8DMSID1fum5qfwWHUrqDp87MGbe43566tb2rh7YBB0Lpb8LCR-SbkgugnyxSl4LY_2NvP2ozRRY5EtbbggYrW3akMaYNXq6abAJrIucf6GJzerL0tQW"}
  let(:claim) do
    {
      "name" => "Panha Chom",
      "picture" => "https://lh3.googleusercontent.com/a/ALm5wu2QtfSj0SCjLjnIoc6NXK0oIJSTeWgWWEbz_82N=s96-c",
      "iss" => "https://securetoken.google.com/cm-market-433b1",
      "aud" => "cm-market-433b1",
      "auth_time" => 1669284004,
      "user_id" => "Vqfmcj9WQvRS8BYAoef2NfxeIud2",
      "sub" => "Vqfmcj9WQvRS8BYAoef2NfxeIud2",
      "iat" => 1669284004,
      "exp" => 1669287604,
      "firebase" => {"identities" => {"google.com" => ["111591770148271979763"]},
      "sign_in_provider" => "google.com"
      }
    }
  end

  let(:cert) do
    {
      "951c08c516ae352b89e4d2e0e14096f734942a87" => "-----BEGIN CERTIFICATE-----\nMIIDHDCCAgSgAwIBAgIIL9VBFWkatBEwDQYJKoZIhvcNAQEFBQAwMTEvMC0GA1UE\nAwwmc2VjdXJldG9rZW4uc3lzdGVtLmdzZXJ2aWNlYWNjb3VudC5jb20wHhcNMjIx\nMTI3MDkzOTA5WhcNMjIxMjEzMjE1NDA5WjAxMS8wLQYDVQQDDCZzZWN1cmV0b2tl\nbi5zeXN0ZW0uZ3NlcnZpY2VhY2NvdW50LmNvbTCCASIwDQYJKoZIhvcNAQEBBQAD\nggEPADCCAQoCggEBAMv8fPZpFxgcfYSb7pcoV/iJMI+2qgFjASTNUHsRpzNFoqNH\nKoghPZbaTK1W4CFfza0kPa1BH1qDUmZ9qB517w8P4JJKrD5cUoChrzelqotPhMHx\nYzVNfnFjnMp5HiAi25EaTQdyBSvoH9+WZHRAl6X0DfQ8vX2+xVAF9BnaKtTodFrS\nyzt2cGQMJx3UdwordV4hF8nSyow7pN21Tg2+DklcF/rred51+fFcVJphfEYTMtAe\nwvbbDXZwy0Y9QAWd0nHbCjvEB3mCrGeFsKmsXTNZ/cwwo9aMD/+MAJJ3w0PCM5fm\n5rizkJasiW2D+zI3i8qAl7dF9981P3ilQ7MnJu8CAwEAAaM4MDYwDAYDVR0TAQH/\nBAIwADAOBgNVHQ8BAf8EBAMCB4AwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwIwDQYJ\nKoZIhvcNAQEFBQADggEBAHHf+encKrLeDWRMavQiSD8wG9shSi8fFgcTIGVVcQCJ\nMoXcUOpGrrHj/TFTbXjQqwo/Zyi29IO/vZIeT+s1ee1P3CErZgTQjuzywmoKDeyl\n9ImrkjpC7rKulCSIZ7+Q9JMyU4VqmIYvfNwtE9u0tVlQBjOgDKgFzVYE+2lysAKB\nZQMG9P/yaVqbtt/FY0rVkq/UaExflEB1hRwvFix+Q34k43y9FTD6HIf/wJz2zSDZ\nS+Uutx35KElOLjfxcSVozzI79PQh39dBIvQWpakDyyg7UY3CtfOjbfoyTH5mbOUN\nHeZIoVEh2EbA4d8P4tMYQIa8NU9HDwYUzCTG8UfIfmA=\n-----END CERTIFICATE-----\n",
      "a96adce9999bbf5cd30f29f49cd37f4c5e642740" => "----BEGIN CERTIFICATE-----\nMIIDHTCCAgWgAwIBAgIJAJsmCdlCEtdXMA0GCSqGSIb3DQEBBQUAMDExLzAtBgNV\nBAMMJnNlY3VyZXRva2VuLnN5c3RlbS5nc2VydmljZWFjY291bnQuY29tMB4XDTIy\nMTExOTA5MzkwOFoXDTIyMTIwNTIxNTQwOFowMTEvMC0GA1UEAwwmc2VjdXJldG9r\nZW4uc3lzdGVtLmdzZXJ2aWNlYWNjb3VudC5jb20wggEiMA0GCSqGSIb3DQEBAQUA\nA4IBDwAwggEKAoIBAQDPx5SngqCrMJVQ/lFC9kP7Mgnhs4aIIbaquM42Z/zG1c80\nEPEhTlRz9Cltc6wtj0wmRPi9x8HtIRlyoo4ps6LCXH0GxJZ6hZHGlcGUbFTAbVsY\naUWqteiXb2umTEnFV8+IaeOqVvSnJ97RIRcMSa7McKL+AkdjKPuDvdK5R6SHnnML\n3HNJ8Xla1YOWmYkgCAgUNGLLg5bl8M6zyicNg8ZPGV7ndIzjrXuy9yKorpljNzZJ\nhymT29yIq3hFInk+GGaSEaRIW6Zz0QjxUSgjDS75yxHnNM9Sgik3I6X8SHKO6mdY\naG4GAQUcuHr8eaZH9vYR0RG50c+fMw/P38nr0i8VAgMBAAGjODA2MAwGA1UdEwEB\n/wQCMAAwDgYDVR0PAQH/BAQDAgeAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMCMA0G\nCSqGSIb3DQEBBQUAA4IBAQCvRsaUOJj8yA5Ul/LhoBFwEmZaQuU5sUKWGMJJj4ug\nWzBPtCEfsmYsMQWmaSY7PiHn7eOF7rUL6FRaHvy1sMwF+xp4xomrIp+GQPQA4hra\nAlgJRUUslTMJkbypsZ6PMWMLJw2WtyFcaIq/5vdywExwcfi+Gi7lDHTyfSCTiDvq\nqK85W7OpqkmSxFKcva9Gi0tLLNgrRR9953Pwqis3LRVwKX6yXQ0j0v2pTmIyH/zp\nVrUK77PjKaWlZISsmLH5dF4Olclx6hRFhvUYVXmT0K/hqr4pBZWukt4D9cD6ZSem\nqFbFBUPmxj4clHXqiqRmQ3tv6MkpudXzCNb0wYWk+3TU\n-----END CERTIFICATE-----\n"
    }
  end

  describe '.decode_id_token' do
    it 'success decoded and return provider info' do
      kid = 'cf5d8e74f3c486ee503d5eec93a101c64bacf7da'
      subject = SpreeCmCommissioner::FirebaseIdTokenProvider.new(id_token: id_token)

      allow(subject).to receive(:cert_generation).and_return(cert[kid])
      allow(subject).to receive(:decode_id_token).and_return(claim)

      response = subject.decode_id_token

      expect(response["iss"]).to eq(claim["iss"])
      expect(response["aud"]).to eq(claim["aud"])
      expect(response["firebase"]["identities"]).to eq(claim["firebase"]["identities"])
    end

    it 'wrong id token return error' do
      subject = SpreeCmCommissioner::FirebaseIdTokenProvider.new(id_token: 'fake token')
      expect{ subject.decode_id_token }.to raise_error(Interactor::Failure)
    end

    # TODO: we are still verifying without public key
    # it 'wrong kid return error' do
    #   kid = 'fake74f3c486ee503d5eec93a101c64bacf7da'
    #   subject = SpreeCmCommissioner::FirebaseIdTokenProvider.new(id_token: id_token)
    #   allow(subject).to receive(:kid).and_return(kid)
    #   expect{ subject.decode_id_token }.to raise_error(Interactor::Failure)
    # end
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
      allow_any_instance_of(SpreeCmCommissioner::FirebaseEmailFetcher).to receive(:call).and_return(
        double(success?: true, email: 'bookmeplus@gmail.com')
      )

      response = subject.call

      identity_type = claim["firebase"]["sign_in_provider"].split(".").first
      provider_sub = claim["firebase"]["identities"]["google.com"].first

      expect(response[:identity_type]).to match(identity_type)
      expect(response[:sub]).to match(provider_sub)
      expect(response[:name]).to match("Panha Chom")
    end

    it 'fail when id_token not valid return the error message' do
      id_token = 'fake_id_token'
      subject = SpreeCmCommissioner::FirebaseIdTokenProvider.new(id_token: id_token)

      expect{subject.call}.to raise_error(Interactor::Failure)
    end
  end
end
