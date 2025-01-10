module SpreeCmCommissioner
  module ContentCachable
    extend ActiveSupport::Concern

    included do
      after_action :set_cache_control_for_cdn
    end

    def max_age
      ENV.fetch('CONTENT_CACHE_MAX_AGE', '180')
    end

    def set_cache_control_for_cdn
      return if response.committed?
      return if response.status != 200

      # max-age: browser cache, s-maxage: server cache
      response.headers['Cache-Control'] = "public, max-age=0, s-maxage=#{max_age}"
      response.headers['Pragma'] = 'no-cache' # For older HTTP/1.0 clients
      response.headers['Expires'] = '0'
    end
  end
end
