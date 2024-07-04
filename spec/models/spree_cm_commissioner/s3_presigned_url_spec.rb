require 'spec_helper'

RSpec.describe SpreeCmCommissioner::S3PresignedUrl, type: :model do
  let(:bucket_name) { 'input-media' }
  let(:object_key ) { 'medias/mission-impossible.mp4' }
  let(:presigned_url) { "https://#{bucket_name}.s3.aws.com/anything" }
  let(:presigned_fields) { {anykey: 'anyvalue'} }
  let(:presigned_object) { double(:presigned_post, url: presigned_url, fields: presigned_fields) }

  describe '#presigned_post' do
    subject { described_class.new(bucket_name, object_key) }

    it 'return s3 presigned object' do
      s3_resource = double(:s3_resource)
      s3_bucket = double(:s3_bucket)

      allow(Aws::S3::Resource).to receive(:new).and_return(s3_resource)
      allow(s3_resource).to receive(:bucket).with(bucket_name).and_return(s3_bucket)
      allow(s3_bucket).to receive(:presigned_post).with(key: object_key, success_action_status: '201').and_return(presigned_object)

      result = subject.send(:presigned_post, bucket_name, object_key)
      expect(result).to eq presigned_object
    end
  end

  describe 'initializer' do

    before(:each) do
      allow_any_instance_of(described_class).to receive(:presigned_post).with(bucket_name, object_key).and_return(presigned_object)
    end

    describe 'delegate' do
      subject { described_class.new(bucket_name, object_key) }

      it 'delegate attrs correctly' do
        expect(subject.url).to eq presigned_object.url
        expect(subject.fields).to eq presigned_object.fields
      end
    end

    describe '#id' do
      context 'uuid is not provided' do
        it 'set id to a generated secure random value' do
          generated_secure_random = 'secure-random'
          allow(SecureRandom).to receive(:uuid).and_return(generated_secure_random)

          subject = described_class.new(bucket_name, object_key)

          expect(subject.id).to eq generated_secure_random
        end
      end

      context 'uuid is provided' do
        it 'set id to a generated secure random value' do
          uuid = SecureRandom::uuid
          subject = described_class.new(bucket_name, object_key, uuid)

          expect(subject.id).to eq uuid
        end
      end
    end

    describe '#error_message' do
      context 'object_key is present' do
        it 'return blank' do
          subject = described_class.new(bucket_name, object_key)
          expect(subject.error_message).to be_blank
        end
      end

      context 'object_key is blank' do
        it 'return error_message' do
          subject = described_class.new(bucket_name, '')
          expect(subject.error_message).to eq I18n.t('s3_signed_url.missing_file_name')
        end
      end
    end

    describe '#s3_direct_post' do
      it 'return presigned_post object' do
        subject = described_class.new(bucket_name, object_key)

        expect(subject.s3_direct_post).to eq presigned_object
      end
    end

    describe '#host' do
      it 'return the host from the presign_post response' do
        subject = described_class.new(bucket_name, object_key)
        expect(subject.host).to eq 'input-media.s3.aws.com'
      end
    end
  end
end