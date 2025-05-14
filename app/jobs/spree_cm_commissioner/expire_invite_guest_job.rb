module SpreeCmCommissioner
  class ExpireInviteGuestJob < ApplicationUniqueJob
    def perform
      SpreeCmCommissioner::InviteGuest
        .where('expiration_date < ?', Time.zone.now)
        .where(claimed_status: :active)
        .find_each do |invite|
          invite.update(claimed_status: :expired)
        end
    end
  end
end
