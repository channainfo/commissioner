module SpreeCmCommissioner
  class VideoOnDemandUpdater < BaseInteractor
    def call
      video_on_demand = context.video_on_demand
      params = context.params

      update_thumbnail(video_on_demand, params) if params[:spree_cm_commissioner_video_on_demand][:thumbnail].present?

      return if video_on_demand.update(
        title: params[:spree_cm_commissioner_video_on_demand][:title],
        description: params[:spree_cm_commissioner_video_on_demand][:description],
        variant_id: params[:spree_cm_commissioner_video_on_demand][:variant_id],
        uuid: params[:spree_cm_commissioner_video_on_demand][:uuid].gsub('-', '')
      )

      context.fail!(error: 'Failed to update VideoOnDemand')
    end

    private

    def update_thumbnail(video_on_demand, params)
      video_on_demand.thumbnail = params[:spree_cm_commissioner_video_on_demand][:thumbnail]
    end
  end
end
