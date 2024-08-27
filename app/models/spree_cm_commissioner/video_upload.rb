module SpreeCmCommissioner
  class VideoUpload < SpreeCmCommissioner::Base

    belongs_to :video_on_demand, class_name: 'SpreeCmCommissioner::VideoOnDemand'

    has_one_attached :file
    has_one_attached :thumbnail

  end
end