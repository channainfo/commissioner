if ENV['EXCEPTION_NOTIFY_ENABLE'] == 'yes'
  Rails.application.config.middleware.use(
    ExceptionNotification::Rack,
    'spree_cm_commissioner/telegram': {
      channel_id: ENV.fetch('EXCEPTION_NOTIFIER_TELEGRAM_CHANNEL_ID', nil)
    }
  )
end
