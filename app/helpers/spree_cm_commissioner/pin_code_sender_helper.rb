module SpreeCmCommissioner
  module PinCodeSenderHelper
    def sender_name(tenant)
      return Spree::Store.default&.name if tenant.nil?

      tenant.active_vendor&.name
    end

    def sender_email(tenant)
      return Spree::Store.default.mail_from_address if tenant.nil?

      tenant.active_vendor&.notification_email
    end

    def logo_url(tenant)
      vendor_or_store = tenant.nil? || tenant.active_vendor.nil? ? Spree::Store.default : tenant.active_vendor
      return unless vendor_or_store&.logo&.attachment&.attached?

      main_app.cdn_image_url(vendor_or_store.logo.attachment.variant(resize_to_limit: [244, 104]))
    end
  end
end
