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

    included do
      serialize :public_metadata, JSON
      serialize :private_metadata, JSON
    end

    def set_public_metafield(key, value)
      self.public_metadata ||= {}
      self.public_metadata[key] = value
      save
    end

    def get_public_metafield(key)
      self.public_metadata ||= {}
      self.public_metadata[key]
    end

    def remove_public_metafield(key)
      self.public_metadata ||= {}
      self.public_metadata.delete(key)
      save
    end

    def set_private_metafield(key, value)
      self.private_metadata ||= {}
      self.private_metadata[key] = value
      save
    end

    def get_private_metafield(key)
      self.private_metadata ||= {}
      self.private_metadata[key]
    end

    def remove_private_metafield(key)
      self.private_metadata ||= {}
      self.private_metadata.delete(key)
      save
    end
  end
end
