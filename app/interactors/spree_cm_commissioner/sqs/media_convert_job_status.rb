module SpreeCmCommissioner
  module Sqs
    class MediaConvertJobStatus
      include Interactor

      delegate :payload, to: :context

      def call
        if message_type == 'media_convert_create_job'
          context.video = handle_submitted_status if status == 'SUBMITTED'
          context.video.save!
        elsif message_type == 'media_convert_job_status'
          context.video = handle_processing_status if status == 'PROGRESSING'
          context.video = handle_complete_status if status == 'COMPLETE'
          context.video = handle_error_status if status == 'ERROR'
          context.video.save!
        end
      end

      private

      def handle_submitted_status
        input_file = payload_info[:input_file]
        file = File.basename(input_file)
        ext  = File.extname(file)
        filename = File.basename(file, ext)
        (uuid, _f, _p, _q) = filename.split('-')[1..]

        video = SpreeCmCommissioner::VideoOnDemand.find_by(uuid: uuid)
        context.fail!(message: "Video with uuid: #{uuid} not found") if video.nil?

        return video if video.status != 'NONE'

        remote_job_id = payload_info[:id]

        video.status = video_status
        video.remote_job_id = remote_job_id
        video
      end

      def handle_processing_status
        video = video_from_payload

        return video if video.status == 'COMPLETE' || video.status == 'ERROR'

        video.status = video_status
        video
      end

      def handle_error_status
        video = video_from_payload

        return video if video.status != 'SUBMITTED'

        video.status = video_status
        video.completed_at = Time.zone.now
        video
      end

      def handle_complete_status
        video = video_from_payload

        video.status = video_status
        video.completed_at = Time.zone.now
        video.output_groups = process_output_groups
        video
      end

      def video_from_payload
        remote_job_id = payload_info[:job_id]
        video = SpreeCmCommissioner::VideoOnDemand.find_by(remote_job_id: remote_job_id)

        context.fail!(message: "Video with remote_job_id: #{remote_job_id} not found") if video.nil?
        video
      end

      def video_status
        SpreeCmCommissioner::VideoOnDemand.statuses[status]
      end

      def status
        payload_info[:status]
      end

      def payload_info
        payload.first
      end

      def message_type
        payload_info[:message_type]
      end

      def process_output_groups
        json_output = output_groups.to_json.gsub("s3://#{output_bucket_name}", "https://#{output_cdn_name}")
        JSON.parse(json_output)
      end

      def output_groups
        payload_info[:output_groups]
      end

      def output_bucket_name
        ENV.fetch('AWS_OUTPUT_BUCKET_NAME', nil)
      end

      def output_cdn_name
        ENV.fetch('AWS_CF_MEDIA_DOMAIN', nil)
      end
    end
  end
end
