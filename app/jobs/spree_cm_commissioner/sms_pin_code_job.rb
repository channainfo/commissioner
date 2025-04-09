module SpreeCmCommissioner
  class SmsPinCodeJob < SpreeCmCommissioner::SmsJob
    # options = { from: xxx, to: xxxx, body: xxxx }
    def perform(options)
      SpreeCmCommissioner::Sms.call(options)
    end
  end
end
