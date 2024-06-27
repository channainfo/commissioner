module SpreeCmCommissioner
  class VideoOnDemand < SpreeCmCommissioner::Base
    include SpreeCmCommissioner::VideoOnDemandBitwise
    include SpreeCmCommissioner::Admin::VideoOnDemandHelper

    enum frame_rate: { FPS_TWEENTY_FOUR: 24, FPS_THIRTY: 30, FPS_SIXTY: 60 }

    belongs_to :variant, class_name: 'Spree::Variant'

    has_one_attached :file
    has_one_attached :thumbnail

    validates :video_quality, :video_protocol, :frame_rate, presence: true
    validates :file, presence: true, if: :new_record?
    validates :thumbnail, presence: true, if: :new_record?
  end
end
