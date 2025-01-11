# lib/cm_app_logger.rb
module CmAppLogger
  def self.log(label:, data: nil)
    message = {
      label: label,
      data: data
    }

    Rails.logger.info(message.to_json)
  end
end
