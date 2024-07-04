module SpreeCmCommissioner
  class VideoOnDemandUpdater < BaseInteractor
    def call
      video_on_demand = context.video_on_demand
      params = context.params
      instance = SpreeCmCommissioner::VideoOnDemand.new

      quality_result = instance.calculate_quality_value(params[:spree_cm_commissioner_video_on_demand])
      protocol_result = instance.calculate_protocol_value(params[:spree_cm_commissioner_video_on_demand])
      frame_rate = SpreeCmCommissioner::VideoOnDemand.frame_rates[params[:spree_cm_commissioner_video_on_demand][:frame_rate].to_sym]
      uuid = SecureRandom.uuid.gsub('-', '')
      new_file_name = generate_new_file_name(video_on_demand, quality_result, protocol_result, frame_rate, uuid)

      update_file_name(video_on_demand, new_file_name) if video_on_demand.file.attached?
      update_thumbnail(video_on_demand, params) if params[:spree_cm_commissioner_video_on_demand][:thumbnail].present?

      return if video_on_demand.update(
        title: params[:spree_cm_commissioner_video_on_demand][:title],
        description: params[:spree_cm_commissioner_video_on_demand][:description],
        variant_id: params[:spree_cm_commissioner_video_on_demand][:variant_id],
        video_quality: quality_result,
        video_protocol: protocol_result,
        frame_rate: frame_rate,
        uuid: uuid
      )

      context.fail!(error: 'Failed to update VideoOnDemand')
    end

    private

    def generate_new_file_name(video_on_demand, quality_result, protocol_result, frame_rate, uuid)
      file_name = File.basename(video_on_demand.file.filename.to_s, File.extname(video_on_demand.file.filename.to_s))
      base_file_name = file_name.split('-')[0...-4].join('-')
      "#{base_file_name}-#{uuid}-f#{frame_rate}-p#{protocol_result}-q#{quality_result}.mp4"
    end

    def update_file_name(video_on_demand, new_file_name)
      video_on_demand.file.blob.update(filename: new_file_name)
    end

    def update_thumbnail(video_on_demand, params)
      video_on_demand.thumbnail = params[:spree_cm_commissioner_video_on_demand][:thumbnail]
    end
  end
end
