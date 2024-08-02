require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Media::SignedUrlGenerator do
  let(:domain) { 'https://bookme.plus' }
  let(:key_pair_id) { 'publickeyid' }
  let(:my_private_key) { File.read(File.expand_path('../../../../fixtures/test_private_key.txt', __FILE__)) }

  let(:s3_object) { 'media/hls/my-media.m3u8' }
  let(:expiration_in_second) { 36000 }

  before(:each) do
    ENV['AWS_CF_MEDIA_DOMAIN'] = domain
    ENV['AWS_CF_PUBLIC_KEY_ID'] = key_pair_id
    ENV['AWS_CF_PRIVATE_KEY'] = my_private_key
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
      # "https://bookme.plus/media/hls/my-media.m3u8?Expires=1720010784&Signature=I3TMiCQALmY2~27Ssnj~8rLC7JYFSmirRMyoIDWjNKxHtSkwabpk64s~onm~JNKY2ACohBf-C~UQi4xezLN7WXuH2jWlWsYsQAiUGTqwFqiSq8v0X~punbUhviBH5hSrJi43gscXnBQg5VDjCDRhREjxyGBpkg9ICTH4rldDemYHYfOrJlPrZOfYVxxlvFFk4GxSesDYQtyZQsfAexVXcoKwKTLu2~lxB2uFhd87mCC2EJGttPvMyidVEzOGNB5d44EJZwwFu9klKQWfL6hvL~LCy1cp29NubKztcvHlpBWm7Fi1YZv82SEDqmGDnB9h7YdMMhCLhrhl~Fcw-yWuVw__&Key-Pair-Id=publickeyid"
      result = subject.send(:sign)
      uri = URI.parse(result)
      queries = Rack::Utils.parse_nested_query(uri.query)

      expect(uri.scheme).to eq 'https'
      expect(uri.host).to eq 'bookme.plus'
      expect(uri.path).to eq '/media/hls/my-media.m3u8'
      expect(queries.keys).to match_array(['Expires', 'Signature', 'Key-Pair-Id'])
      expect(queries['Expires']).to be_present
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