module SpreeCmCommissioner
  class UniqueDeviceTokenCronExecutor < BaseInteractor
    def call
      device_tokens = fetch_device_tokens
      duplicates = find_duplicates(device_tokens)
      remove_duplicates(duplicates)
    end

    private

    def fetch_device_tokens
      SpreeCmCommissioner::DeviceToken.all
    end

    def find_duplicates(device_tokens)
      device_tokens.group(:registration_token).having('count(*) > 1').pluck(:registration_token)
    end

    def remove_duplicates(duplicates)
      duplicates.each do |registration_token|
        device_tokens = SpreeCmCommissioner::DeviceToken.where(registration_token: registration_token)
        device_tokens.order(updated_at: :desc).offset(1).destroy_all
      end
    end
  end
end
