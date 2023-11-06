require 'spec_helper'

RSpec.describe SpreeCmCommissioner::AccountRecover do
  let!(:user) { create(:cm_user, password: '12345678', email: 'abc@cm.com', account_deletion_at: Time.current) }

   describe '#call' do

      it 'update account_restored_at and acount_deletion_at ' do

        params = { login: user.email , password: user.password }

        context = SpreeCmCommissioner::AccountRecover.call(params)

        expect(context.user.account_deletion_at).to eq nil
        expect(context.user.account_restored_at).not_to eq nil
      end

      it 'not update account_restored_at if account is not temporary delete' do

        user.account_deletion_at = nil
        user.save

        params = { login: user.email , password: user.password }

        context = SpreeCmCommissioner::AccountRecover.call(params)

        expect(context.success?).to eq false
        expect(context.message).to eq 'User is not temporary deleted'
      end
   end
end
