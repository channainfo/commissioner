FactoryBot.define do
  factory :cm_video_on_demand, class: 'SpreeCmCommissioner::VideoOnDemand' do
    title { FFaker::Name.name }
    description { FFaker::LoremUA.paragraph }
    variant
    frame_rate { SpreeCmCommissioner::VideoOnDemand.frame_rates[:FPS_TWEENTY_FOUR] }

    uuid { SecureRandom::uuid.delete('-') }
    status { SpreeCmCommissioner::VideoOnDemand.statuses[:NONE] }

    video_quality do
      SpreeCmCommissioner::VideoOnDemandBitwise::QUALITY_BIT_FIELDS[:low] |
      SpreeCmCommissioner::VideoOnDemandBitwise::QUALITY_BIT_FIELDS[:standard] |
      SpreeCmCommissioner::VideoOnDemandBitwise::QUALITY_BIT_FIELDS[:medium]
    end

    video_protocol do
      SpreeCmCommissioner::VideoOnDemandBitwise::PROTOCOL_BIT_FIELDS[:p_hls] |
      SpreeCmCommissioner::VideoOnDemandBitwise::PROTOCOL_BIT_FIELDS[:p_dash] |
      SpreeCmCommissioner::VideoOnDemandBitwise::PROTOCOL_BIT_FIELDS[:p_file]
    end
  end
end