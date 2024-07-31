module Spree
  module Api
    module V2
      module Storefront
        class UserGuestsController < GuestsController
          def collection
            spree_current_user.guests
          end

          # override
          def parent
            spree_current_user
          end
        end
      end
    end
  end
end
