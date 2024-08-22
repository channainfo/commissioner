module SpreeCmCommissioner
  class VideoOnDemandUpdater < BaseInteractor
    def call
      video_on_demand = context.video_on_demand
      params = context.params

      update_file(video_on_demand, params) if params[:spree_cm_commissioner_video_on_demand][:file].present?
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

    def generate_new_file_name(file, quality_result, protocol_result, frame_rate, uuid)
      file_name = File.basename(file.original_filename, File.extname(file.original_filename))
      "#{file_name}-#{uuid}-f#{frame_rate}-p#{protocol_result}-q#{quality_result}.mp4"
    end

    def update_file(video_on_demand, params)
      video_file = params[:spree_cm_commissioner_video_on_demand][:file]
      quality_result = video_on_demand[:video_quality]
      protocol_result = video_on_demand[:video_protocol]
      frame_rate = SpreeCmCommissioner::VideoOnDemand.frame_rates[video_on_demand[:frame_rate]]
      uuid = params[:spree_cm_commissioner_video_on_demand][:uuid].gsub('-', '')

      new_file_name = generate_new_file_name(video_file, quality_result, protocol_result, frame_rate, uuid)
      video_file.original_filename = new_file_name
      video_on_demand.file = video_file
    end

    def update_thumbnail(video_on_demand, params)
      video_on_demand.thumbnail = params[:spree_cm_commissioner_video_on_demand][:thumbnail]
    end
  end
end
