module SpreeCmCommissioner
  class VideoOnDemandCreator < BaseInteractor
    def call
      video_on_demand_params = context.video_on_demand_params

      instance = SpreeCmCommissioner::VideoOnDemand.new
      quality_result = instance.calculate_quality_value(video_on_demand_params)
      protocol_result = instance.calculate_protocol_value(video_on_demand_params)
      frame_rate = SpreeCmCommissioner::VideoOnDemand.frame_rates[video_on_demand_params[:frame_rate]]

      uuid = SecureRandom.uuid.gsub('-', '')
      new_file_name = generate_new_file_name(video_on_demand_params[:file], quality_result, protocol_result, frame_rate, uuid)
      video_on_demand_params[:file].original_filename = new_file_name
      permitted_params = permit_params(video_on_demand_params, quality_result, protocol_result, frame_rate, uuid)

      create_video_on_demand(permitted_params)
    end

    private

    def generate_new_file_name(file, quality_result, protocol_result, frame_rate, uuid)
      file_name = File.basename(file.original_filename, File.extname(file.original_filename))
      "#{file_name}-#{uuid}-f#{frame_rate}-p#{protocol_result}-q#{quality_result}.mp4"
    end

    def permit_params(params, quality_result, protocol_result, frame_rate, uuid)
      params.merge(
        uuid: uuid,
        video_quality: quality_result,
        video_protocol: protocol_result,
        frame_rate: frame_rate
      ).permit(:title, :description, :uuid, :file, :thumbnail, :variant_id, :video_quality, :video_protocol, :frame_rate)
    end

    def create_video_on_demand(permitted_params)
      video_on_demand = SpreeCmCommissioner::VideoOnDemand.new(permitted_params)

      if video_on_demand.save
        context.video_on_demand = video_on_demand
      else
        context.fail!(error: 'Failed to create VideoOnDemand')
      end
    end
  end
end
