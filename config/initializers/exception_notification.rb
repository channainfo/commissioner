if ENV['EXCEPTION_NOTIFY_ENABLE'] == 'yes'
  Rails.application.config.middleware.use(
    ExceptionNotification::Rack,
    'spree_cm_commissioner/telegram': {
      token: ENV.fetch('EXCEPTION_TELEGRAM_BOT_TOKEN', nil),
      channel_id: ENV.fetch('EXCEPTION_NOTIFIER_TELEGRAM_CHANNEL_ID', nil)
    }
  )
end
