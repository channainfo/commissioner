require 'spec_helper'


RSpec.describe SpreeCmCommissioner::ProfileImageUpdater do
  describe '#call' do
    context 'with valid file url' do
      it 'adds user with new profile picture' do
        user = create(:cm_user)
        url = 'spec/support/assets/user/profile_image.png'

        attrs = {
          user: user,
          url: url
        }

        context = SpreeCmCommissioner::ProfileImageUpdater.call(attrs)

        expect(context.success?).to eq true
        user.reload
        expect(context.user.profile).to be_present
        expect(user.profile.attachment.filename.to_s).to eq('profile_image.png')
      end
    end

    context 'with invalid file url' do
      it 'return error' do
        user = create(:cm_user)
        url = '/foo.jpg'
        attrs = {
          user: user,
          url: url
        }

        update_context = SpreeCmCommissioner::ProfileImageUpdater.call(attrs)

        expect(update_context.success?).to eq false
        expect(update_context.message).to eq 'No such file or directory @ rb_sysopen - /foo.jpg'
        expect(update_context.user.profile).to be_blank
      end
    end
  end
end