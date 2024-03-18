module SpreeCmCommissioner
  class AffiliateBanner < Spree::Base
    has_many :banner_clicks
    has_secure_token :code, length: 32

    # mount_uploader :banner, SpreeCmCommissioner::AffiliateBannerUploader

    before_create :set_attrs

    STATUS_ACTIVE = 'active'.freeze
    STATUS_INACTIVE = 'inactive'.freeze

    scope :effective, -> { where('start_date <= ?', Date.current).where('end_date >= ?', Date.current).where(status: AffiliateBanner::STATUS_ACTIVE) }

    def set_attrs
      self.status = AffiliateBanner::STATUS_ACTIVE
    end

    def active?
      status == AffiliateBanner::STATUS_ACTIVE
    end

    def toggle_status
      self.status = if active?
                      AffiliateBanner::STATUS_INACTIVE
                    else
                      AffiliateBanner::STATUS_ACTIVE
                    end

      save!
    end

    def self.hq
      find_by(name: 'HQ')
    end
  end
end
