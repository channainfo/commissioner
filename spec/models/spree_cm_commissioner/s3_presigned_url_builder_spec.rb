require 'spec_helper'

RSpec.describe SpreeCmCommissioner::S3PresignedUrlBuilder, type: :model do
  let(:bucket_name) { 'input-media' }
  let(:object_key ) { 'medias/mission-impossible.mp4' }
  let(:file_name) { 'my-memorable-pic.png' }

  let(:presigned_url) { "https://#{bucket_name}.s3.aws.com/anything" }
  let(:presigned_fields) { {anykey: 'anyvalue'} }
  let(:presigned_object) { double(:presigned_post, url: presigned_url, fields: presigned_fields) }

  subject { described_class.new(bucket_name: bucket_name, object_key: object_key) }

  describe '.call' do
    it 'return the presigned_url object' do
      my_uuid = 'my-uuid'
      s3_presigned_url = double(:s3_presigned_url)

      allow_any_instance_of(described_class).to receive(:uuid).and_return(my_uuid)
      allow(SpreeCmCommissioner::S3PresignedUrl).to receive(:new).with(bucket_name, object_key, my_uuid).and_return(s3_presigned_url)

      result = described_class.call(bucket_name: bucket_name, object_key: object_key)

      expect(result).to eq s3_presigned_url
    end
  end

  describe '#object_key' do
    context 'object_key is present' do
      it 'return the object_key' do
        result = subject.send(:object_key)
        expect(result).to eq object_key
      end
    end

    context 'file_name exist instead of object_key ' do
      subject { described_class.new(bucket_name: bucket_name, file_name: file_name) }

      it 'reutrn object_key contructing from the file_name' do
        generated_uuid = 'my-uuid'
        allow_any_instance_of(described_class).to receive(:uuid).and_return(generated_uuid)

        result = subject.send(:object_key)
        expect(result).to eq 'uploads/my-uuid/my-memorable-pic.png'
      end
    end
  end

  describe '#bucket_name' do
    context 'bucket name is present' do
      it 'return the bucket name' do
        result = subject.send(:bucket_name)
        expect(result).to eq bucket_name
      end
    end

    context 'bucket name is not present' do
      subject { described_class.new(bucket_name: nil, object_key: object_key) }

      it 'return the default bucket name' do
        default_bucket = 'cm-production'
        allow_any_instance_of(described_class).to receive(:default_bucket_name).and_return(default_bucket)

        result = subject.send(:bucket_name)
        expect(result).to eq(default_bucket)
      end
    end
  end

  describe '#uuid' do
    context 'uuid is present' do
      it 'return the uuid' do
        my_uuid = 'my-uuid'
        subject = described_class.new(bucket_name: bucket_name, file_name: file_name, uuid: my_uuid)

        result = subject.send(:uuid)
        expect(result).to eq my_uuid
      end
    end

    context 'uuid is not present' do
      it 'generate uuid once' do
        generated_uuid = 'generated-uuid'
        allow(SecureRandom).to receive(:uuid).and_return(generated_uuid)

        result = subject.send(:uuid)
        expect(result).to eq generated_uuid
      end
    end

    it 'memoroizable' do
      subject = described_class.new( bucket_name: bucket_name, file_name: file_name, uuid: nil)

      result = subject.send(:uuid)
      memoirable = subject.send(:uuid)

      expect(result).to eq memoirable
      expect(result).to_not be_blank
    end
  end

  describe '#call' do
    it "set the options and return S3PresignedUrl" do
      my_uuid = 'my-uuid'
      s3_presigned_url = double(:s3_presigned_url)

      allow_any_instance_of(described_class).to receive(:uuid).and_return(my_uuid)
      allow(SpreeCmCommissioner::S3PresignedUrl).to receive(:new).with(bucket_name, object_key, my_uuid).and_return(s3_presigned_url)

      result = described_class.new(bucket_name: bucket_name, object_key: object_key).call

      expect(result).to eq s3_presigned_url
    end
  end
end