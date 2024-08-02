require 'spec_helper'

describe 'MediaConvertQueues', type: :request do
  describe '#create' do
    let!(:webhook_subscriber) { create(:cm_webhook_subscriber) }
    let!(:uuid) { '7777776811db43f8bd33e8613b852f08' }
    let!(:job_id) { '1722483175671-mtvkv3' }
    let!(:media_submitted) do
      { _json: [
          {
            "id": "1722483175671-mtvkv3",
            "arn": "arn:aws:mediaconvert:ap-southeast-1:636758493619:jobs/1722483175671-mtvkv3",
            "status": "SUBMITTED",
            "created_at": "2024-08-01 03:32:55 +0000",
            "message_type": "media_convert_create_job",
            "input_file": "s3://input-production-cm/medias/2024-08/ELECTRIC-7777776811db43f8bd33e8613b852f08-f24-p3-q7.mp4"
          }
        ]
      }
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
      { _json:
        [
          {
            "message_type": "media_convert_job_status",
            "arn": "arn:aws:mediaconvert:ap-southeast-1:636758493619:jobs/1722483175671-mtvkv3",
            "job_id": "1722483175671-mtvkv3",
            "status": "COMPLETE",
            "output_groups": output_groups
          }
        ]
      }
    end

    let!(:video) { create(:cm_video_on_demand, uuid: uuid) }

    subject { described_class.new(payload: media_submitted) }

    before(:each) do
      ENV['AWS_OUTPUT_BUCKET_NAME'] = 'output-production-cm'
      ENV['AWS_CF_MEDIA_DOMAIN'] = 'medias.bookme.plus'
    end

    let!(:headers) do
      {
        'X-Api-Name': webhook_subscriber.name,
        'X-Api-Key': webhook_subscriber.api_key
      }
    end

    context 'when job status is SUBMITTED' do
      it 'return errors if the video with uuid is not found' do
        video.uuid = SecureRandom::uuid.delete('-')
        video.save!

        post '/api/webhook/media_convert_queues', params: media_submitted, headers: headers

        json_response = JSON.parse(response.body, symbolize_names: true)

        expect(response.status).to eq 403
        expect(json_response).to match( message: 'Video with uuid: 7777776811db43f8bd33e8613b852f08 not found' )
      end

      it 'return status 200 and does nothing if the status is not NONE' do
        status = 'COMPLETE'
        video.status = status
        video.save!

        post '/api/webhook/media_convert_queues', params: media_submitted, headers: headers

        expect(response.status).to eq 200
      end


      it 'update the video and returns 200 status if video is found' do
        post '/api/webhook/media_convert_queues', params: media_submitted, headers: headers

        video.reload

        expect(response.status).to eq 200
        expect(video.status).to eq 'SUBMITTED'
        expect(video.frame_rate).to eq 'FPS_TWEENTY_FOUR'
        expect(video.remote_job_id).to eq job_id
        expect(video.output_groups).to be_empty
      end
    end

    context 'when job status is COMPLETE' do
      it 'updates the video and returns 200 if the video status is SUBMITTED and contain remote_job_id' do
        video.remote_job_id = job_id
        video.status = 'SUBMITTED'
        video.save!

        post '/api/webhook/media_convert_queues', params: media_complete, headers: headers

        video.reload

        expect(response.status).to eq 200
        expect(video.status).to eq 'COMPLETE'
        expect(video.frame_rate).to eq 'FPS_TWEENTY_FOUR'
        expect(video.remote_job_id).to eq job_id
        expect(video.output_groups).to_not be_empty
      end

      it 'return error if remote_job_id is not found' do
        post '/api/webhook/media_convert_queues', params: media_complete, headers: headers

        json_response = JSON.parse(response.body, symbolize_names: true)

        expect(response.status).to eq 403
        expect(json_response).to match(message: 'Video with remote_job_id: 1722483175671-mtvkv3 not found')
      end
    end
  end
end
