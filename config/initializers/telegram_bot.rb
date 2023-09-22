Telegram.bots_config = {
  # Telegram.bot.get_updates
  default: ENV.fetch('DEFAULT_TELEGRAM_BOT_API_TOKEN', nil),

  # Telegram.bots[:exception_notifier]
  exception_notifier: ENV.fetch('EXCEPTION_TELEGRAM_BOT_TOKEN', nil)
}
