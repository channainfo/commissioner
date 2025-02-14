module Spree
  module Api
    module V2
      module Billing
        class AuthController < Spree::Api::V2::BaseController
          # skip_before_action :verify_authenticity_token

          # POST /api/v2/billing/auth/register
          def register
            user = Spree::User.new(user_params)
            if user.save

              customer_params_with_user = customer_params.merge(user_id: user.id)
              customer = SpreeCmCommissioner::Customer.create(customer_params_with_user)

              render json: {
                message: 'User registered successfully',
                user: user.as_json(only: %i[id email phone_number]),
                customer: customer.as_json(only: %i[id name email phone_number]) # Include relevant fields
              }, status: :created
            else
              render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
            end
          end

          # POST /api/v2/billing/auth/login
          def login
            user = Spree::User.find_by(email: params[:email])
            if user&.valid_password?(params[:password])
              token = encode_jwt(user.id)

              # Fetch the associated customer
              customer = SpreeCmCommissioner::Customer.find_by(user_id: user.id)
              customer_id = customer&.id

              render json: {
                message: 'Login successful',
                token: token,
                user: user.as_json(only: %i[id email]),
                customer_id: customer_id
              }, status: :ok
            else
              render json: { error: 'Invalid email or password' }, status: :unauthorized
            end
          end

          private

          def customer_params
            params.require(:customer).permit(:first_name, :last_name, :email, :gender, :dob, :phone_number, :place_id, :status, :vendor_id,
                                             taxon_ids: []
            )
          end

          def user_params
            params.require(:user).permit(:email, :password, :password_confirmation, :phone_number)
          end

          def encode_jwt(user_id)
            payload = { user_id: user_id }
            JWT.encode(payload, Rails.application.secrets.secret_key_base, 'HS256')
          end
        end
      end
    end
  end
end
