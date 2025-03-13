module SpreeCmCommissioner
  class Invite < SpreeCmCommissioner::Base
    belongs_to :taxon, class_name: 'Spree::Taxon'
    belongs_to :inviter, class_name: 'Spree::User'
    has_many :invite_user_events, class_name: 'SpreeCmCommissioner::InviteUserEvent', dependent: :destroy
    scope :active, -> { where('expires_at > ?', Time.current) }

    after_create :set_expiration

    def set_expiration
      update(expires_at: 3.days.from_now)
    end

    def invite_url
      "#{Spree::Store.default.formatted_url}/invite/#{token}?utm_source=email"
    end

    def url_valid?
      expires_at.present? && expires_at > Time.current
    end
  end
end
