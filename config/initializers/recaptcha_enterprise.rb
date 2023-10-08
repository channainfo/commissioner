Google::Cloud::RecaptchaEnterprise.configure do |config|
  config.credentials = Rails.application.credentials.google_service_account
end
