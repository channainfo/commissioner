module SpreeCmCommissioner
  class Video < Spree::Asset
    include ::Rails.application.routes.url_helpers

    has_one_attached :attachment

    validates :attachment, attached: true, content_type: %r{\Avideo/.*\z}

    default_scope { includes(attachment_attachment: :blob) }

    def original_url
      cdn_image_url(attachment)
    end
  end
end
