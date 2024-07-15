require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Media::SignedCookieGenerator do
  let(:domain) { 'https://bookme.plus' }
  let(:key_pair_id) { 'publickeyid' }
  let(:my_private_key) { File.read(File.expand_path('../../../../fixtures/test_private_key.txt', __FILE__)) }
  let(:s3_object) { 'media/hls/my-media.m3u8' }
  let(:expiration_in_second) { 36000 }

  before(:each) do
    ENV['CF_DOMAIN'] = domain
    ENV['CF_PUBLIC_KEY_ID'] = key_pair_id
    ENV['CF_PRIVATE_KEY'] = my_private_key
  end

  subject { described_class.new(s3_object_key: s3_object, expiration_in_second: expiration_in_second) }

  describe "delegate" do
    it "deletegate fields correctly" do
      expect(subject.s3_object_key).to eq s3_object
      expect(subject.expiration_in_second).to eq expiration_in_second
    end
  end

  describe '#distribution_domain' do
    it 'return the distribution domain' do
      result = subject.send(:distribution_domain)
      expect(result).to eq(domain)
    end
  end

  describe '#key_pair_id' do
    it 'return the key_pair_id' do
      result = subject.send(:key_pair_id)
      expect(result).to eq(key_pair_id)
    end
  end

  describe '#private_key' do
    it 'return the private_key' do
      result = subject.send(:private_key)
      expect(result).to eq(my_private_key)
    end
  end

  describe '#expiration_time' do
    it 'return the expiration_time' do
      result = subject.send(:expiration_time)
      expect(result >= expiration_in_second.seconds.from_now.to_i).to eq true
    end
  end

  describe '#call' do
    it 'invoke the sign method' do
      expect(subject).to receive(:sign)

      subject.send(:call)
    end
  end

  describe '#sign' do
    it 'set context result to the signed url' do
      # {"CloudFront-Policy"=>"eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9ib29rbWUucGx1cy9tZWRpYS9obHMvKiIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTcyMDAxMTAxMn19fV19", "CloudFront-Signature"=>"djZNkt7yHcc1BfrkZ5hct007SrqR~R16GJe8CdMZpwScDzBTlbE7652oUNzy5L3M8KIVHscF4Ve84ief6VgD0JU7lzHWEICPjKMUrhoxENudIwwvVfVZFlc-fhH0CINwFj0CJfFK5CpvkH6RyUcnt17mEbj6m-swFDd3i63ErBn4oMGu1rAl-HXgDxnr2Jg8431Xd1fFolhgI0eiaWQ1S9Dd5ryIKE4c4pEMvKx636YzbRn4helzhzUTU34vaFx5jZUclhy~gqJwDaWYtoEqG3h704PBZyVFyrNfhGzXMxPw-yM7JnuUY~CbUr1eubALf1EiwTt8e3YgctSDP3I1zQ__", "CloudFront-Key-Pair-Id"=>"publickeyid"}
      result = subject.send(:sign)

      expect(result.keys).to match_array(['CloudFront-Policy', 'CloudFront-Signature', 'CloudFront-Key-Pair-Id'])
      expect(result['CloudFront-Policy']).to be_present
      expect(result['CloudFront-Signature']).to be_present
      expect(result['CloudFront-Key-Pair-Id']).to be_present
    end
  end

  describe '#signer' do
    it 'return set the signer value' do
      signer = double(:signer)

      expect(Aws::CloudFront::CookieSigner).to receive(:new).with(
        key_pair_id: subject.send(:key_pair_id),
        private_key: subject.send(:private_key)
      ).and_return(signer)

      result = subject.send(:signer)
      expect(result).to eq signer
    end
  end

  describe '#url' do
    it 'return url to be signed' do
      expected_url = 'https://bookme.plus/media/hls/my-media.m3u8'
      url = subject.send(:url)
      expect(url).to eq(expected_url)
    end
  end
end