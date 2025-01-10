# override this on your server.
module SpreeCmCommissioner
  class ApplicationUniqueJob < ::ApplicationUniqueJob
    queue_as :default
  end
end
