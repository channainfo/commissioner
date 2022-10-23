module DoorkeeperAuthHelper
  def update_oauth_resource_owner_to_creator
    @oauth_resource_owner.is_creator = true
    @oauth_resource_owner.first_name = 'Phil'
    @oauth_resource_owner.last_name = "Dunphy #{SecureRandom.base64(10)}" ## to create unique slug
    @oauth_resource_owner.save
  end

  def update_oauth_resource_owner_to_admin
    @oauth_resource_owner.spree_roles << create(:admin_role)
  end

  def update_oauth_application_to_third_party
    @oauth_application.update_column(:application_type, "third_party")
  end


  def create_resource_owner_token
    @oauth_application = create(:oauth_application)
    @oauth_resource_owner = create(:user)
    @oauth_access_token = create(:oauth_access_token,
                                 application: @oauth_application,
                                 resource_owner_id: @oauth_resource_owner.id)
    @oauth_access_token
  end

  def create_application_token
    @oauth_application = create(:oauth_application)
    @oauth_access_token = create(:oauth_access_token, application: @oauth_application)
    @oauth_access_token
  end

  def set_social_manager_resoucre_owner_token
    doorkeeper_token = create_resource_owner_token
    @current_vendor = create(:vendor)
    @current_social = create(:social_manager, managable_id: @current_vendor.id, managable_type: @current_vendor.class.to_s)

    @oauth_resource_owner.vendors = [@current_vendor]
    @oauth_resource_owner.save

    add_header_token(doorkeeper_token.token)
  end

  def set_vendor_resoucre_owner_token
    doorkeeper_token = create_resource_owner_token
    @current_vendor = create(:vendor)

    @oauth_resource_owner.vendors = [@current_vendor]
    @oauth_resource_owner.save

    add_header_token(doorkeeper_token.token)
  end

  def set_resource_owner_token
    doorkeeper_token = create_resource_owner_token
    add_header_token(doorkeeper_token.token)
  end

  def set_application_token
    doorkeeper_token = create_application_token
    add_header_token(doorkeeper_token.token)
  end

  def add_header_token(token)
    headers = {
      'Host' => ENV['DEFAULT_URL_HOST'],
      'Accept' => 'application/json',
      'Authorization' => "Bearer #{token}"
    }

    headers.each do |key, value|
      @request.headers[key] = value
    end
  end
end
