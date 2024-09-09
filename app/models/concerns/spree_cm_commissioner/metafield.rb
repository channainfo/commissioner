module SpreeCmCommissioner
  module Metafield
    extend ActiveSupport::Concern

    ATTRIBUTE_TYPES = %w[
      float
      integer
      string
      boolean
      date
      time
      selection
    ].freeze
  end
end
