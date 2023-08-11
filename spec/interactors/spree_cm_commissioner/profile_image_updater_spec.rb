require 'spec_helper'
require 'webmock/rspec'

RSpec.describe SpreeCmCommissioner::ProfileImageUpdater do
  describe '#call' do
    context 'with valid file url' do
      it 'adds user with new profile picture' do
        user = create(:cm_user)
        url = 'https://res.cloudinary.com/demo/image/twitter/1330457336.jpg'

        stub_request(:get, url).to_return(status: 200, body: 'content', headers: {})

        attrs = {
          user: user,
          url: url
        }

        context = SpreeCmCommissioner::ProfileImageUpdater.call(attrs)

        expect(context.success?).to eq true
        user.reload
        expect(context.user.profile).to be_present
        expect(user.profile.attachment.filename.to_s).to eq('1330457336.jpg')
      end
    end

    context 'with invalid file url' do
      it 'return error' do
        user = create(:cm_user)

        url = '/foo.jpg'

        stub_request(:get, url).to_return(status: 200, body: 'content', headers: {})

        attrs = {
          user: user,
          url: url
        }

        update_context = SpreeCmCommissioner::ProfileImageUpdater.call(attrs)
        
        expect(update_context.success?).to eq false
        expect(update_context.user.profile).to be_blank
      end
    end
  end
end
