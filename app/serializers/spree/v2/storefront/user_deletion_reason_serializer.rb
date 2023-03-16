module Spree
  module V2
    module Storefront
      class UserDeletionReasonSerializer < BaseSerializer
        set_type :user_deletion_reason

        attributes :title, :skip_reason, :reason_desc, :title_tran, :reason_desc_tran
      end
    end
  end
end
