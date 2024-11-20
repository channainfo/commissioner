module SpreeCmCommissioner
  module ContentCachable
    extend ActiveSupport::Concern

    included do
      after_action :set_cache_control_for_cdn
    end

    def max_age
      ENV.fetch('CONTENT_CACHE_MAX_AGE', '7200')
    end

    def set_cache_control_for_cdn
      return unless request.get? || request.head?
      return unless request.base_url == ENV['CONTENT_HOST_URL']

      response.set_header('Cache-Control', "public, max-age=#{max_age}")
    end
  end
end
