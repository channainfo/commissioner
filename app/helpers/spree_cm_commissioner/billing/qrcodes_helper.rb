module SpreeCmCommissioner
  module Billing
    module QrcodesHelper
      def payment_qrcode_image(qrcode)
        return if qrcode.blank?

        image_tag main_app.rails_blob_url(qrcode.attachment), alt: 'qrcode', style: 'width: 150px;'
      end
    end
  end
end
