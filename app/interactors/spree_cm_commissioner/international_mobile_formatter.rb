module SpreeCmCommissioner
  class InternationalMobileFormatter < BaseInteractor
    def call
      country_code = context.country_code || 'kh'
      return if context.phone_number.nil?

      mobile_phone = context.phone_number.gsub(/[()\s-]/, '')
      phone = Phonelib.parse(mobile_phone, country_code)

      international = phone.international
      international = international.present? ? international.gsub(/[()\s-]/, '') : nil

      context.formatted_phone_number = international
    end
  end
end
