require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Media::SignedPathGenerator do
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

      # https://bookme.plus/media/hls/my-media.m3u8?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9ib29rbWUucGx1cy9tZWRpYS9obHMvKiIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTcyMDAxMDQ3MH19fV19&Signature=Mnzq7tL5v7hLalOw2n7P4e5QD6~F9do0K4o2DDAypDOKS0BiIwxo0c6w08kb-t~QDZdN3GNXl-WV5pmXIqVYQHAcbzfw~p6VqqEIjXwAB5umQq7Q0~Uq8K6kiNd6ghz5Yb6-xBGoPnuQutc7mUyN8sIOFiVmka4yo8oWWJqM7cPUdN2VEcxXYN9BQpm350QfYBkhH6HQGybkCAnnhKdXY6cHM-gToRPB3KuQm9hSPovo3HqYJR~lc0lG9pByEYxN3lkTqwuS7EPPXNP3Qo0jkey2kamuveQPIGmAf9-7gpLXpvVMGfDJbCyHXknPBtv-4jzvu61L0tSutPYP5L7h2g__&Key-Pair-Id=publickeyid
      result = subject.send(:sign)
      uri = URI.parse(result)
      queries = Rack::Utils.parse_nested_query(uri.query)

      expect(uri.scheme).to eq 'https'
      expect(uri.host).to eq 'bookme.plus'
      expect(uri.path).to eq '/media/hls/my-media.m3u8'
      expect(queries.keys).to match_array(['Policy', 'Signature', 'Key-Pair-Id'])
      expect(queries['Policy']).to be_present
      expect(queries['Signature']).to be_present
      expect(queries['Key-Pair-Id']).to be_present
    end
  end

  describe '#signer' do
    it 'return set the signer value' do
      signer = double(:signer)

      expect(Aws::CloudFront::UrlSigner).to receive(:new).with(
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