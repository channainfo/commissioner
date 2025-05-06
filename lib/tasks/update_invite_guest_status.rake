# recommend to be used in schedule.yml & manually access in /sidekiq/cron
namespace :spree_cm_commissioner do
  desc 'Update Invite Guest claimed status to expired'
  task update_invite_guest_status: :environment do
    SpreeCmCommissioner::ExpireInviteGuestJob.perform_now
  end
end
