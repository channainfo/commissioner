module SpreeCmCommissioner
  class PinCode < ApplicationRecord
    has_secure_token

    enum contact_type: { 'phone_number' => 0, 'email' => 1 }

    validates :code, length: { maximum: 6 }
    validates :contact, presence: true
    validates :contact, email: true, if: :email?
    validates :type, presence: true

    before_create :set_attrs
    attr_accessor :long_life_pin_code, :user_validation_check # skip set expire pin code when validate on create user

    PIN_CODE_NOT_FOUND = 'not_found'.freeze
    PIN_CODE_EXPIRED = 'expired'.freeze
    PIN_CODE_ATTEMPT_REACHED = 'reached_max_attempt'.freeze
    PIN_CODE_MISMATCHED = 'not_match'.freeze
    PIN_CODE_OK = 'ok'.freeze

    def check?(code)
      return PIN_CODE_EXPIRED if expired?
      return PIN_CODE_ATTEMPT_REACHED if number_of_attempt_reached?

      increment_attempt

      if self.code == code
        set_expire
        save
        PIN_CODE_OK
      else
        save
        PIN_CODE_MISMATCHED
      end
    end

    def set_expire
      return if user_validation_check
      return if long_life_pin_code

      self.expired_at = Time.zone.now
    end

    def self.pin_code_valid?(token)
      pin_code = find_by(token: token)

      return false if pin_code.blank? || pin_code.expired? || pin_code.number_of_attempt_reached?

      true
    end

    def self.mark_expired!(token)
      pin_code = find_by(token: token)
      return if pin_code.blank?

      pin_code.expire
      pin_code.save
    end

    def check_contact_phone(phone_number, country_code)
      if contact.start_with?('+')
        contact == SpreeCmCommissioner::PinCode.intel_phone_number(phone_number, country_code)
      else
        contact.gsub(/\s/, '') == phone_number.gsub(/\s/, '')
      end
    end

    def self.intel_phone_number(phone_number, country_code = 'kh')
      return phone_number if phone_number.start_with?('+')

      country_code ||= 'kh'

      phone_parser = Phonelib.parse(phone_number, country_code)
      if phone_parser.valid?
        phone_parser.international.gsub!(/[() -]/, '')
      else
        phone_number
      end
    end

    def self.check?(options)
      pin_code = find_by(token: options[:id])

      return PIN_CODE_NOT_FOUND if pin_code.nil?

      if options[:phone_number].present?
        return PIN_CODE_NOT_FOUND unless pin_code.check_contact_phone(options[:phone_number], options[:country_code])
      elsif pin_code.contact != options[:email]
        return PIN_CODE_NOT_FOUND
      end

      pin_code.long_life_pin_code = options[:long_life_pin_code]
      pin_code.check?(options[:code])
    end

    def max_attempt_allowed
      3
    end

    def expires_in_seconds
      30 * 60 # 30 mins
    end

    def expire
      self.expired_at = Time.zone.now
    end

    def increment_attempt
      self.number_of_attempt += 1
    end

    def number_of_attempt_reached?
      self.number_of_attempt >= max_attempt_allowed
    end

    def expired?
      expired_at.present? || (created_at + expires_in.seconds < Time.zone.now)
    end

    def readable_type
      type_mapper[type]
    end

    def type_mapper
      {
        'MyStore::PinCodeContactUpdate' => I18n.t('pincode.readable_type.contact_update'),
        'MyStore::PinCodeLogin' => I18n.t('pincode.readable_type.login'),
        'MyStore::PinCodeForgetPassword' => I18n.t('pincode.readable_type.reset_password'),
        'MyStore::PinCodeRegistration' => I18n.t('pincode.readable_type.registration_code'),
        'MyStore::PinCodeMobileConfirm' => I18n.t('pincode.readable_type.confirmation_code'),
        'MyStore::PinCodeUpdateUserLogin' => I18n.t('pincode.readable_type.update_user_login'),
        'MyStore::PinCodeEmailConfirm' => I18n.t('pincode.readable_type.confirmation_code')
      }
    end

    private

    def set_attrs
      self.code = Random.new.bytes(8).bytes.join[0, 6]
      self.expires_in = expires_in_seconds
    end
  end
end
