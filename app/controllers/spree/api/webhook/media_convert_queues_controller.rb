module Spree
  module Api
    module Webhook
      class MediaConvertQueuesController < BaseController
        skip_before_action :load_subsriber

        # {
        #   '_json' => [
        #     { 'id' => '1718809546016-qkgk9n',
        #       'arn' => 'arn:aws:mediaconvert:ap-southeast-1:636758493619:jobs/1718809546016-qkgk9n',
        #       'status' => 'SUBMITTED',
        #       'created_at' => '2024-06-19 15:05:46 +0000',
        #       'message_type' => 'media_convert_create_job',
        #       'input_file' => 's3://input-production-cm/medias/cohesion.mp4'
        #     }
        #   ]
        # }
        def create
          context_result = SpreeCmCommissioner::Sqs::MediaConvertJobStatus.call(payload: sqs_payload)
          if context_result.success?
            head :ok
          else
            render json: { message: context_result.message }, status: :forbidden
          end
        end

        private

        def sqs_payload
          params[:_json]
        end
      end
    end
  end
end
