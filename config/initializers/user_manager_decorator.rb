require 'firebase-admin-sdk'

module Firebase
  module Admin
    module Auth
      module UserManagerDecorator
        def get_user_by_sub(query)
          sub = query[:sub]
          return if sub.blank?

          payload = {
            federatedUserId: {
              providerId: 'google.com',
              rawId: sub
            }
          }
          response = @client.post(with_path('accounts:lookup'), payload).body
          users = response['users'] if response
          UserRecord.new(users[0]) if users.is_a?(Array) && users.any?
        end
      end
    end
  end
end

Firebase::Admin::Auth::UserManager.prepend(Firebase::Admin::Auth::UserManagerDecorator)
