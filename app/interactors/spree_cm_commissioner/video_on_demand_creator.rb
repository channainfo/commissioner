module SpreeCmCommissioner
  class VideoOnDemandCreator < BaseInteractor
    def call
      video_on_demand_params = context.video_on_demand_params

      instance = SpreeCmCommissioner::VideoOnDemand.new
      quality_result = instance.calculate_quality_value(video_on_demand_params)
      protocol_result = instance.calculate_protocol_value(video_on_demand_params)
      frame_rate = SpreeCmCommissioner::VideoOnDemand.frame_rates[video_on_demand_params[:frame_rate]]

      uuid = video_on_demand_params[:uuid]
      permitted_params = permit_params(video_on_demand_params, quality_result, protocol_result, frame_rate, uuid)

      video_on_demand = SpreeCmCommissioner::VideoOnDemand.new(permitted_params)

      if video_on_demand.save
        context.video_on_demand = video_on_demand
      else
        context.fail!(error: 'Failed to create VideoOnDemand')
      end
    end

    private

    def permit_params(params, quality_result, protocol_result, frame_rate, uuid)
      params.merge(
        uuid: uuid,
        video_quality: quality_result,
        video_protocol: protocol_result,
        frame_rate: frame_rate
      ).permit(:title, :description, :uuid, :variant_id, :video_quality, :video_protocol, :frame_rate)
    end
  end
end
