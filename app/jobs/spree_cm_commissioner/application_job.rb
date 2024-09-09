module SpreeCmCommissioner
  class ApplicationJob < ::ApplicationJob
    queue_as :default
  end
end
