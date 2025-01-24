module SpreeCmCommissioner
  class UserUnreadNotificationCountJob < ApplicationUniqueJob
    queue_as :user_updates

    def perform(user_id)
      user = Spree::User.find_by(id: user_id)

      SpreeCmCommissioner::UserUnreadNotificationCountUpdater.call(user: user)
    end
  end
end
