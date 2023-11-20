module  SpreeCmCommissioner
  class Sms < BaseInteractor
    def call
      context.fail!(message: I18n.t('sms.to.blank')) if context.to.blank?
      context.fail!(message: I18n.t('sms.body.blank')) if context.body.blank?

      begin
        create_sms_log(sms_options)
        create_message(sms_options)
      rescue StandardError => e
        context.sms_log.error = e.message
        context.sms_log.save
        context.fail!(message: e.message)
      end
    end

    private

    def adapter
      context.adapter ||= SmsAdapter::Plasgate.new
    end

    def create_message(sms_options)
      adapter.create_message(sms_options) { |attrs| update_sms_log(attrs) }
    end

    # sms adapter can decide whether to update additional sms log fields
    def update_sms_log(attributes)
      attributes = attributes.slice(:external_ref)
      context.sms_log.update(attributes)
    end

    def create_sms_log(sms_options)
      context.sms_log = SpreeCmCommissioner::SmsLog.create(
        from_number: sms_options[:from],
        to_number: sms_options[:to],
        body: sms_options[:body],
        adapter_name: adapter.class.name.demodulize
      )
    end

    def sms_options
      opts = { to: context.to, body: context.body }
      opts[:to] = sanitize(opts[:to]) if opts[:to].present?
      opts[:from] = from_number
      opts
    end

    def from_number
      context.from || ENV['SMS_SENDER_ID'].presence || 'SMS Info'
    end

    def sanitize(number)
      return nil if number.blank?
      return number if number.start_with?('+')

      result = SpreeCmCommissioner::InternationalMobileFormatter.call(phone_number: number)
      result.formatted_phone_number
    end
  end
end
