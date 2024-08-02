require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Sqs::MediaConvertJobStatus do
  let!(:uuid) { '7777776811db43f8bd33e8613b852f08' }
  let!(:job_id) { '1722483175671-mtvkv3' }
  let!(:media_error) do
    [
      {
        "message_type": "media_convert_job_status",
        "arn": "arn:aws:mediaconvert:ap-southeast-1:636758493619:jobs/1722483175671-mtvkv3",
        "job_id": "1722483175671-mtvkv3",
        "status": "ERROR",
        "output_groups": []
      }
    ]
  end

  let!(:media_progressing) do
    [
      {
        "message_type": "media_convert_job_status",
        "arn": "arn:aws:mediaconvert:ap-southeast-1:636758493619:jobs/1722483175671-mtvkv3",
        "job_id": "1722483175671-mtvkv3",
        "status": "PROGRESSING",
        "output_groups": []
      }
    ]
  end

  let!(:media_submitted) do
    [
      {
        "id": "1722483175671-mtvkv3",
        "arn": "arn:aws:mediaconvert:ap-southeast-1:636758493619:jobs/1722483175671-mtvkv3",
        "status": "SUBMITTED",
        "created_at": "2024-08-01 03:32:55 +0000",
        "message_type": "media_convert_create_job",
        "input_file": "s3://input-production-cm/medias/2024-08/ELECTRIC-7777776811db43f8bd33e8613b852f08-f24-p3-q7.mp4"
      }
    ]
  end

  let!(:output_groups) do
    [
      {
        "outputDetails": [
          {
            "outputFilePaths": [
              "s3://output-production-cm/medias/file/ELECTRIC-7777776811db43f8bd33e8613b852f08-f24-p3-q7/ELECTRIC-7777776811db43f8bd33e8613b852f08-f24-p3-q7-640_360.mp4"
            ],
            "durationInMs": 315748,
            "videoDetails": {
              "widthInPx": 640,
              "heightInPx": 360,
              "averageBitrate": 500468
            }
          },
          {
            "outputFilePaths": [
              "s3://output-production-cm/medias/file/ELECTRIC-7777776811db43f8bd33e8613b852f08-f24-p3-q7/ELECTRIC-7777776811db43f8bd33e8613b852f08-f24-p3-q7-854_480.mp4"
            ],
            "durationInMs": 315748,
            "videoDetails": {
              "widthInPx": 854,
              "heightInPx": 480,
              "averageBitrate": 1000956
            }
          },
          {
            "outputFilePaths": [
              "s3://output-production-cm/medias/file/ELECTRIC-7777776811db43f8bd33e8613b852f08-f24-p3-q7/ELECTRIC-7777776811db43f8bd33e8613b852f08-f24-p3-q7-1280_720.mp4"
            ],
            "durationInMs": 315748,
            "videoDetails": {
              "widthInPx": 1280,
              "heightInPx": 720,
              "averageBitrate": 2502943
            }
          }
        ],
        "type": "FILE_GROUP"
      },
      {
        "outputDetails": [
          {
            "outputFilePaths": [
              "s3://output-production-cm/medias/hls/ELECTRIC-7777776811db43f8bd33e8613b852f08-f24-p3-q7/ELECTRIC-7777776811db43f8bd33e8613b852f08-f24-p3-q7-640_360.m3u8"
            ],
            "durationInMs": 315748,
            "videoDetails": {
              "widthInPx": 640,
              "heightInPx": 360,
              "averageBitrate": 500361
            }
          },
          {
            "outputFilePaths": [
              "s3://output-production-cm/medias/hls/ELECTRIC-7777776811db43f8bd33e8613b852f08-f24-p3-q7/ELECTRIC-7777776811db43f8bd33e8613b852f08-f24-p3-q7-854_480.m3u8"
            ],
            "durationInMs": 315748,
            "videoDetails": {
              "widthInPx": 854,
              "heightInPx": 480,
              "averageBitrate": 1000717
            }
          },
          {
            "outputFilePaths": [
              "s3://output-production-cm/medias/hls/ELECTRIC-7777776811db43f8bd33e8613b852f08-f24-p3-q7/ELECTRIC-7777776811db43f8bd33e8613b852f08-f24-p3-q7-1280_720.m3u8"
            ],
            "durationInMs": 315748,
            "videoDetails": {
              "widthInPx": 1280,
              "heightInPx": 720,
              "averageBitrate": 2502040
            }
          }
        ],
        "playlistFilePaths": [
          "s3://output-production-cm/medias/hls/ELECTRIC-7777776811db43f8bd33e8613b852f08-f24-p3-q7/ELECTRIC-7777776811db43f8bd33e8613b852f08-f24-p3-q7.m3u8"
        ],
        "type": "HLS_GROUP"
      }
    ]
  end

  let!(:media_complete) do
    [
      {
        "message_type": "media_convert_job_status",
        "arn": "arn:aws:mediaconvert:ap-southeast-1:636758493619:jobs/1722483175671-mtvkv3",
        "job_id": "1722483175671-mtvkv3",
        "status": "COMPLETE",
        "output_groups": output_groups
      }
    ]
  end

  let!(:video) { create(:cm_video_on_demand, uuid: uuid) }

  subject { described_class.new(payload: media_submitted) }

  before(:each) do
    ENV['AWS_OUTPUT_BUCKET_NAME'] = 'output-production-cm'
    ENV['AWS_CF_MEDIA_DOMAIN'] = 'medias.bookme.plus'
  end

  describe '.call' do
    context 'job submitted' do
      it 'set video status and remote_job_id' do
        result = described_class.call(payload: media_submitted)

        expect(result.success?).to eq true
        expect(result.video).to eq video
        expect(result.video.status).to eq 'SUBMITTED'
        expect(result.video.remote_job_id).to eq job_id
        expect(result.video.output_groups).to match({})
      end
    end

    context 'job progressing' do
      it 'set video status from submitted to progressing' do
        video.status = 'SUBMITTED'
        video.remote_job_id = job_id
        video.save!

        result = described_class.call(payload: media_progressing)

        expect(result.success?).to eq true
        expect(result.video).to eq video
        expect(result.video.status).to eq 'PROGRESSING'
      end
    end

    context 'job error' do
      it 'set video status, completed_at' do
        video.status = 'SUBMITTED'
        video.remote_job_id = job_id
        video.save!

        result = described_class.call(payload: media_error)

        expect(result.success?).to eq true
        expect(result.video).to eq video
        expect(result.video.status).to eq 'ERROR'
        expect(result.video.completed_at).to be_present
      end
    end

    context 'job complete' do
      it 'set video status, completed_at and ouput group' do
        video.remote_job_id = job_id
        video.save!

        result = described_class.call(payload: media_complete)

        expect(result.success?).to eq true
        expect(result.video).to eq video
        expect(result.video.status).to eq 'COMPLETE'
        expect(result.video.completed_at).to be_present
        expect(result.video.remote_job_id).to eq job_id
        expect(result.video.output_groups).to be_present
      end
    end
  end


  describe '#process_output_groups' do
    it 'parse output group to have the correct cdn' do
      subject = described_class.new(payload: media_complete)
      result = subject.send(:process_output_groups)
      file_groups = result[0]['outputDetails']

      hls_groups = result[1]['outputDetails']
      hls_playlist = result[1]['playlistFilePaths']

      expect(file_groups[0]['outputFilePaths'][0]).to eq 'https://medias.bookme.plus/medias/file/ELECTRIC-7777776811db43f8bd33e8613b852f08-f24-p3-q7/ELECTRIC-7777776811db43f8bd33e8613b852f08-f24-p3-q7-640_360.mp4'
      expect(file_groups[1]['outputFilePaths'][0]).to eq 'https://medias.bookme.plus/medias/file/ELECTRIC-7777776811db43f8bd33e8613b852f08-f24-p3-q7/ELECTRIC-7777776811db43f8bd33e8613b852f08-f24-p3-q7-854_480.mp4'
      expect(file_groups[2]['outputFilePaths'][0]).to eq 'https://medias.bookme.plus/medias/file/ELECTRIC-7777776811db43f8bd33e8613b852f08-f24-p3-q7/ELECTRIC-7777776811db43f8bd33e8613b852f08-f24-p3-q7-1280_720.mp4'

      expect(hls_groups[0]['outputFilePaths'][0]).to eq 'https://medias.bookme.plus/medias/hls/ELECTRIC-7777776811db43f8bd33e8613b852f08-f24-p3-q7/ELECTRIC-7777776811db43f8bd33e8613b852f08-f24-p3-q7-640_360.m3u8'
      expect(hls_groups[1]['outputFilePaths'][0]).to eq 'https://medias.bookme.plus/medias/hls/ELECTRIC-7777776811db43f8bd33e8613b852f08-f24-p3-q7/ELECTRIC-7777776811db43f8bd33e8613b852f08-f24-p3-q7-854_480.m3u8'
      expect(hls_groups[2]['outputFilePaths'][0]).to eq 'https://medias.bookme.plus/medias/hls/ELECTRIC-7777776811db43f8bd33e8613b852f08-f24-p3-q7/ELECTRIC-7777776811db43f8bd33e8613b852f08-f24-p3-q7-1280_720.m3u8'

      expect(hls_playlist).to match(['https://medias.bookme.plus/medias/hls/ELECTRIC-7777776811db43f8bd33e8613b852f08-f24-p3-q7/ELECTRIC-7777776811db43f8bd33e8613b852f08-f24-p3-q7.m3u8'])

    end
  end

  describe '#handle_submitted_status' do
    context 'no video with the uuid is found' do
      it 'raises error' do
        video.uuid = SecureRandom.uuid.delete('-')
        video.save!

        subject = described_class.new(payload: media_submitted)
        expect { subject.send(:handle_submitted_status) }.to raise_error Interactor::Failure
        expect(subject.context.message).to eq 'Video with uuid: 7777776811db43f8bd33e8613b852f08 not found'
      end
    end

    context 'video status is not NONE' do
      it 'return the video and do nothing' do
        status = 'COMPLETE'
        remote_job_id = 'anything'
        video.status = status
        video.remote_job_id = remote_job_id
        video.save!

        subject = described_class.new(payload: media_submitted)
        result = subject.send(:handle_submitted_status)

        expect(result.status).to eq status
        expect(result.remote_job_id).to eq remote_job_id
      end
    end

    context 'video status NONE' do
      it 'set video status to SUBMITTED and remote_job_id' do
        subject = described_class.new(payload: media_submitted)
        result = subject.send(:handle_submitted_status)

        expect(result.status).to eq 'SUBMITTED'
        expect(result.remote_job_id).to eq job_id
      end
    end
  end

  describe '#handle_error_status' do
    context 'no video with remote_job_id is found' do
      it 'raises error' do
        subject = described_class.new(payload: media_error)
        expect { subject.send(:handle_error_status) }.to raise_error Interactor::Failure
        expect(subject.context.message).to eq 'Video with remote_job_id: 1722483175671-mtvkv3 not found'
      end
    end

    context 'video status is not SUBMITTED' do
      it 'return the video and do nothing' do
        status = 'COMPLETE'
        video.status = status
        video.remote_job_id = job_id
        video.save!

        subject = described_class.new(payload: media_error)
        result = subject.send(:handle_error_status)

        expect(result.status).to eq status
      end
    end

    context 'video status SUBMITTED' do
      it 'set video status to ERROR and completed_at' do
        status = 'SUBMITTED'
        video.status = status
        video.remote_job_id = job_id
        video.save!

        subject = described_class.new(payload: media_error)
        result = subject.send(:handle_error_status)

        expect(result.status).to eq 'ERROR'
        expect(result.completed_at).to be_present
      end
    end
  end

  describe '#handle_processing_status' do
    context 'no video with remote_job_id is found' do
      it 'raises error' do
        subject = described_class.new(payload: media_progressing)
        expect { subject.send(:handle_processing_status) }.to raise_error Interactor::Failure
        expect(subject.context.message).to eq 'Video with remote_job_id: 1722483175671-mtvkv3 not found'
      end
    end

    context 'video status is COMPLETE' do
      it 'return the video and do nothing' do
        status = 'COMPLETE'
        video.status = status
        video.remote_job_id = job_id
        video.save!

        subject = described_class.new(payload: media_progressing)
        result = subject.send(:handle_processing_status)

        expect(result.status).to eq status
      end
    end

    context 'video status ERROR' do
      it 'return the video and do nothing' do
        status = 'ERROR'
        video.status = status
        video.remote_job_id = job_id
        video.save!

        subject = described_class.new(payload: media_progressing)
        result = subject.send(:handle_processing_status)

        expect(result.status).to eq 'ERROR'
      end
    end

    context 'video status is SUBMITTED' do
      it 'return the video and do nothing' do
        status = 'SUBMITTED'
        video.status = status
        video.remote_job_id = job_id
        video.save!

        subject = described_class.new(payload: media_progressing)
        result = subject.send(:handle_processing_status)

        expect(result.status).to eq 'PROGRESSING'
      end
    end
  end

  describe '#handle_complete_status' do
    context 'no video with remote_job_id is found' do
      it 'raises error' do
        subject = described_class.new(payload: media_complete)
        expect { subject.send(:handle_complete_status) }.to raise_error Interactor::Failure
        expect(subject.context.message).to eq 'Video with remote_job_id: 1722483175671-mtvkv3 not found'
      end
    end

    context 'video is found' do
      it 'set video status to COMPLETE, completed_at and output_groups' do
        video.status = 'SUBMITTED'
        video.remote_job_id = job_id
        video.save!

        subject = described_class.new(payload: media_complete)
        result = subject.send(:handle_complete_status)

        expect(result.status).to eq 'COMPLETE'
        expect(result.completed_at).to be_present
        expect(result.output_groups).to_not be_empty
      end
    end
  end

  describe '#video_from_payload' do
    context 'no video with remote_job_id is found' do
      it 'raises error' do
        subject = described_class.new(payload: media_complete)
        expect { subject.send(:video_from_payload) }.to raise_error Interactor::Failure
        expect(subject.context.message).to eq 'Video with remote_job_id: 1722483175671-mtvkv3 not found'
      end
    end

    context 'video is found' do
      it 'return the video' do
        video.remote_job_id = job_id
        video.save!

        subject = described_class.new(payload: media_complete)
        result = subject.send(:video_from_payload)

        expect(result).to eq video
      end
    end
  end

end