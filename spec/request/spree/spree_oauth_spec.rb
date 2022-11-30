require 'spec_helper'

describe 'Spree Oauth Spec', type: :request do
  describe 'token#create' do
    context 'grant type password' do
      it 'successfully logged user' do
        user = create(:user)

        post "/spree_oauth/token", params: {
          "grant_type": "password",
          "username": user.login,
          "password": user.password,
        }

        json_response_body = JSON.parse(response.body)
        expect(json_response_body.keys).to contain_exactly(
          'access_token',
          'token_type',
          'expires_in',
          'refresh_token',
          'created_at'
        )
      end
    end

    context 'grant type password' do
      it 'successfully logged user' do
        user = create(:user)

        post "/spree_oauth/token", params: {
          "grant_type": "password",
          "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6ImE5NmFkY2U5OTk5YmJmNWNkMzBmMjlmNDljZDM3ZjRjNWU2NDI3NDAiLCJ0eXAiOiJKV1QifQ.eyJuYW1lIjoiUGFuaGEgQ2hvbSIsInBpY3R1cmUiOiJodHRwczovL2xoMy5nb29nbGV1c2VyY29udGVudC5jb20vYS9BTG01d3UyUXRmU2owU0NqTGpuSW9jNk5YSzBvSUpTVGVXZ1dXRWJ6XzgyTj1zOTYtYyIsImlzcyI6Imh0dHBzOi8vc2VjdXJldG9rZW4uZ29vZ2xlLmNvbS9jbS1tYXJrZXQtNDMzYjEiLCJhdWQiOiJjbS1tYXJrZXQtNDMzYjEiLCJhdXRoX3RpbWUiOjE2NjkyODQwMDQsInVzZXJfaWQiOiJWcWZtY2o5V1F2UlM4QllBb2VmMk5meGVJdWQyIiwic3ViIjoiVnFmbWNqOVdRdlJTOEJZQW9lZjJOZnhlSXVkMiIsImlhdCI6MTY2OTI4NDAwNCwiZXhwIjoxNjY5Mjg3NjA0LCJmaXJlYmFzZSI6eyJpZGVudGl0aWVzIjp7Imdvb2dsZS5jb20iOlsiMTExNTkxNzcwMTQ4MjcxOTc5NzYzIl19LCJzaWduX2luX3Byb3ZpZGVyIjoiZ29vZ2xlLmNvbSJ9fQ.R95hhSSQI-LEYgjJx9IQ-weuDIZRc7umxVURhdqWvii3pC67GZkPoXMT0QqnehBb4DB7TQyUN_AGbO_G34HlOJZ3g1L7_f_45zdnGodZdW0he4zrGaqNj59pe1oppyvnG9EwupXwjjP1p-ASMvxUJ5VW4_TvkwJx9nIyB3PHNuqvPEvg8eqHACdxQ4lrqJClPgxJoHvh9rLgQmPLbwGGMDBDH8DMSID1fum5qfwWHUrqDp87MGbe43566tb2rh7YBB0Lpb8LCR-SbkgugnyxSl4LY_2NvP2ozRRY5EtbbggYrW3akMaYNXq6abAJrIucf6GJzerL0tQW",
        }

        json_response_body = JSON.parse(response.body)
        p json_response_body
        expect(json_response_body.keys).to contain_exactly(
          'access_token',
          'token_type',
          'expires_in',
          'refresh_token',
          'created_at'
        )
      end
    end
  end
end
