# In case we need to raise exception.
module SpreeCmCommissioner
  class UserAuthenticator
    # :username, :password
    # :id_token
    def self.call!(params)
      context = auth_context(params)
      raise exception(context.message) unless context.success?

      user = context.user

      # Check if user.tenant_id is nil first to keep our old logic work as usual
      if user.tenant_id.nil? && params[:client_id].blank? && params[:client_secret].blank?
        return user
      elsif params[:client_id].present? && params[:client_secret].present?
        oauth_application = find_oauth_application(params)
        raise exception(I18n.t('authenticator.invalid_client_credentials')) unless oauth_application

        validate_tenant_match!(user, oauth_application)
      else
        raise exception(I18n.t('authenticator.invalid_or_missing_params'))
      end

      user
    end

    def self.auth_context(params)
      tenant_id = find_oauth_application(params)&.tenant_id

      case flow_type(params)
      when 'login_auth'
        options = { login: params[:username], password: params[:password], tenant_id: tenant_id }
        SpreeCmCommissioner::UserPasswordAuthenticator.call(options)
      when 'social_auth'
        options = { id_token: params[:id_token] }
        SpreeCmCommissioner::UserIdTokenAuthenticator.call(options)
      when 'telegram_web_app_auth'
        options = { telegram_init_data: params[:telegram_init_data], telegram_bot_username: params[:tg_bot] }
        SpreeCmCommissioner::UserTelegramWebAppAuthenticator.call(options)
      when 'vattanac_bank_web_app_auth'
        options = { session_id: params[:session_id] }
        SpreeCmCommissioner::UserVattanacBankWebAppAuthenticator.call(options)
      end
    end

    def self.flow_type(params)
      return 'login_auth' if params.key?(:username) && params.key?(:password)
      return 'social_auth' if params.key?(:id_token)
      return 'telegram_web_app_auth' if params.key?(:telegram_init_data) && params.key?(:tg_bot)
      return 'vattanac_bank_web_app_auth' if params.key?(:session_id)

      raise exception(I18n.t('authenticator.invalid_or_missing_params'))
    end

    def self.exception(message)
      Doorkeeper::Errors::DoorkeeperError.new(message)
    end

    def self.validate_tenant_match!(user, oauth_application)
      return if user.tenant_id == oauth_application.tenant_id

      raise ActiveRecord::RecordNotFound
    end

    def self.find_oauth_application(params)
      Spree::OauthApplication.find_by(uid: params[:client_id], secret: params[:client_secret])
    end
  end
end
