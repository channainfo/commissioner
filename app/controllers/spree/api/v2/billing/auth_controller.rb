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
              render json: { message: 'User registered successfully', user: user }, status: :created
            else
              render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
            end
          end

          # POST /api/v2/billing/auth/login
          def login
            user = Spree::User.find_by(email: params[:email])
            if user&.valid_password?(params[:password])
              token = encode_jwt(user.id)
              render json: { message: 'Login successful', token: token, user: user }, status: :ok
            else
              render json: { error: 'Invalid email or password' }, status: :unauthorized
            end
          end

          private

          def user_params
            params.require(:user).permit(:email, :password, :password_confirmation)
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
