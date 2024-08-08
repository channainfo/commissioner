module SpreeCmCommissioner
  class VideoOnDemand < SpreeCmCommissioner::Base
    include SpreeCmCommissioner::VideoOnDemandBitwise
    include SpreeCmCommissioner::Admin::VideoOnDemandHelper

    enum frame_rate: { FPS_TWEENTY_FOUR: 24, FPS_THIRTY: 30, FPS_SIXTY: 60 }
    enum status: { NONE: 0, SUBMITTED: 1, PROGRESSING: 2, COMPLETE: 3, ERROR: 4 }

    belongs_to :variant, class_name: 'Spree::Variant'

    has_one_attached :file
    has_one_attached :thumbnail

    validates :video_quality, :video_protocol, :frame_rate, :uuid, presence: true
  end
end
