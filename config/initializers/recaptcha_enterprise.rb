Google::Cloud::RecaptchaEnterprise.configure do |config|
  config.credentials = Rails.application.credentials.recaptcha_enterprise_service_account
end
