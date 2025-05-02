# lib/cm_app_logger.rb
module CmAppLogger
  def self.log(label:, data: nil)
    message = { label: label, data: data }
    start_time = Time.current
    Rails.logger.info(message.to_json)

    return unless block_given?

    # Capture the block’s return value and return it to preserve existing behavior for callers expecting that value.
    block_result = yield

    message[:start_time] = start_time
    message[:duration_ms] = (Time.current - start_time) * 1000
    Rails.logger.info(message.to_json)
    block_result
  end
end
