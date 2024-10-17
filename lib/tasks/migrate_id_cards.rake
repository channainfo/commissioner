# recommend to be used in schedule.yml & manually access in /sidekiq/cron
namespace :spree_cm_commissioner do
  desc 'Migrate guest_id to id_cardable in CmIdCards'
  task migrate_id_cards: :environment do
    SpreeCmCommissioner::IdCard.where.not(guest_id: nil).find_each do |id_card|
      id_card.update(id_cardable_type: 'SpreeCmCommissioner::Guest', id_cardable_id: id_card.guest_id)
    end
  end
end
