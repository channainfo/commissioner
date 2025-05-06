module SpreeCmCommissioner
  class InviteGuest < SpreeCmCommissioner::Base
    enum invite_type: { invite: 0, open: 1, sponsor: 2 }
    enum claimed_status: { active: 0, claimed: 1, expired: 2, revoked: 3 }

    belongs_to :variant, class_name: 'Spree::Variant'
    belongs_to :order, class_name: 'Spree::Order'
    belongs_to :taxon, class_name: 'Spree::Taxon'

    self.whitelisted_ransackable_attributes = %w[claimed_status]
  end
end
