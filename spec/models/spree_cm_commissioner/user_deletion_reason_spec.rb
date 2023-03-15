require 'spec_helper'

RSpec.describe UserDeletionReason, type: :model do
  describe 'translations' do
    describe '#title_tran' do
      it 'returns correct translations to title key' do
        deletion_reason = create(:user_deletion_reason)

        title_tran = deletion_reason.title_tran
        translation_from_title = I18n.t(deletion_reason.title)

        expect(title_tran).to eq translation_from_title
      end
    end

    describe '#reason_desc_tran' do
      it 'returns correct translations to description key' do
        deletion_reason = create(:user_deletion_reason)

        reason_desc_tran = deletion_reason.reason_desc_tran
        translation_from_reason_desc = I18n.t(deletion_reason.reason_desc)

        expect(reason_desc_tran).to eq translation_from_reason_desc
      end
    end
  end

  describe 'migration seed' do
    describe '.generate_default_deletions' do
      it 'returns reasons from table matched with deletion reasons from seed' do
        UserDeletionReason.delete_all
        UserDeletionReason.generate_default_deletions

        reasons_from_seed = UserDeletionReason.default_deletions
        reasons_from_table = UserDeletionReason.all

        expect(reasons_from_table.count).to eq (reasons_from_seed.count)
        expect(reasons_from_table[0].title).to eq (reasons_from_seed[0][:title])
        expect(reasons_from_table[0].skip_reason).to eq (reasons_from_seed[0][:skip_reason])
      end
    end
  end
end