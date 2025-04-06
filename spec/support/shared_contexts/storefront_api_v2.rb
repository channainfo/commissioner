shared_context 'Storefront API v2' do
  let(:oauth_application) { Spree::OauthApplication.find_or_create_by!(name: 'BookMe+') }

  def signed_in_headers(user)
    token = Spree::OauthAccessToken.create!(resource_owner: user, application_id: oauth_application.id)
    { 'Authorization': "Bearer #{token.token}" }
  end
end
