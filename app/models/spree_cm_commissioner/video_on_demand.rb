module SpreeCmCommissioner
  class VideoOnDemand < SpreeCmCommissioner::Base
    belongs_to :variant, class_name: 'Spree::Variant'
    has_one_attached :file
    has_one_attached :thumbnail

    validates :title, :description, :file, :thumbnail, presence: true
    validates :variant_id, uniqueness: true
  end
end
