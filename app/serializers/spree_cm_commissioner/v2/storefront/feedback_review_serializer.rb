module SpreeCmCommissioner
  module V2
    module Storefront
      class FeedbackReviewSerializer < BaseSerializer
        set_type :feedback_review

        attributes :rating, :comment, :created_at, :updated_at

        has_one :user, serializer: ::Spree::V2::Storefront::UserSerializer
        has_one :review, serializer: SpreeCmCommissioner::V2::Storefront::ReviewSerializer
      end
    end
  end
end
