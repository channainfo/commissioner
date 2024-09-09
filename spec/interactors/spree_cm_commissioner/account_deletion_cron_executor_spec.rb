require 'spec_helper'

RSpec.describe SpreeCmCommissioner::AccountDeletionCronExecutor do
  describe '#account deletion cron ' do
    it 'return true when account deleted_at is set ' do
      user = create(:cm_user, deleted_at: Time.now)

      user.save!
      existing_user = Spree::User.base_class.find_by id: user.id

      expect(existing_user).to eq nil
      expect(Spree::User.only_deleted.last).to eq user
    end

    it 'return only user who not reach to 30 day after soft delete' do
      user_2 = create(:cm_user, deleted_at: Time.now)
      user_3 = create(:cm_user, deleted_at: 1.months.ago)
      user_4 = create(:cm_user, deleted_at: 2.months.ago)
      user_5 = create(:cm_user, deleted_at: 3.months.ago)

      context = described_class.new
      results = context.call

      expect(Spree::User.only_deleted.length).to eq 1
    end
  end
end