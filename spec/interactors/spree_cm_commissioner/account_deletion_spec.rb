require 'spec_helper'

RSpec.describe SpreeCmCommissioner::AccountDeletion do
  let!(:user) { create(:cm_user) }


  describe '# save_survey' do
    it 'save surveys when password, params are validated' do
      reason = create(:user_deletion_reason)
      subject = described_class.new(
        user: user ,
        user_deletion_reason_id: reason.id

      )
      subject.save_survey
      survey = SpreeCmCommissioner::UserDeletionSurvey.last

      expect(subject.context.success?).to eq true
      expect(survey.user_deletion_reason_id).to eq reason.id

    end
  end

  describe '#destroy_user' do
    it 'success when delete user' do
      subject = described_class.new(user: user)
      subject.destroy_user
      user.reload
      expect(user.account_deletion_at).to_not eq nil
    end
  end

  describe '#call' do
    it 'return account_deletion_at not nil when destroy user success' do
      subject = described_class.new(user: user, is_from_backend: true)
      allow(subject).to receive(:validate_user_account).and_return(user)
      subject.call
      expect(subject.context.user.account_deletion_at).to_not eq nil
    end

    it 'return success when delete from admin' do
      subject = described_class.new(user: user, is_from_backend: true)
      subject.call
      expect(subject.context.user.account_deletion_at).to_not eq nil
      expect(subject.context.success?).to eq true
    end
  end
end
