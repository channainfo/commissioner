require 'aws-sdk-ecs'

# TODO: UI to check all instances, max sessions, active_sessions, and available slots
module SpreeCmCommissioner
  class WaitingRoomLatestSystemMetadataPuller < BaseInteractor
    def call
      ecs_client = Aws::ECS::Client.new(
        region: ENV.fetch('AWS_REGION'),
        access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
        secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY')
      )

      tasks_response = ecs_client.list_tasks(
        cluster: ENV.fetch('AWS_CLUSTER_NAME'),
        launch_type: 'FARGATE'
      )

      SpreeCmCommissioner::WaitingRoomSystemMetadataSetter.new.set(server_running_count: [tasks_response.task_arns.size, 1].max)
    end
  end
end
