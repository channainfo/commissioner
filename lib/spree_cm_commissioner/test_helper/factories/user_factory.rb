# Refactored with / from:
# spree_core-4.4.0/lib/spree/testing_support/factories/user_factory.rb

FactoryBot.define do
  sequence :cm_id_token do |_n|
    'eyJhbGciOiJSUzI1NiIsImtpZCI6ImE5NmFkY2U5OTk5YmJmNWNkMzBmMjlmNDljZDM3ZjRjNWU2NDI3NDAiLCJ0eXAiOiJKV1QifQ.eyJuYW1lIjoiUGFuaGEgQ2hvbSIsInBpY3R1cmUiOiJodHRwczovL2xoMy5nb29nbGV1c2VyY29udGVudC5jb20vYS9BTG01d3UyUXRmU2owU0NqTGpuSW9jNk5YSzBvSUpTVGVXZ1dXRWJ6XzgyTj1zOTYtYyIsImlzcyI6Imh0dHBzOi8vc2VjdXJldG9rZW4uZ29vZ2xlLmNvbS9jbS1tYXJrZXQtNDMzYjEiLCJhdWQiOiJjbS1tYXJrZXQtNDMzYjEiLCJhdXRoX3RpbWUiOjE2NjkyODQwMDQsInVzZXJfaWQiOiJWcWZtY2o5V1F2UlM4QllBb2VmMk5meGVJdWQyIiwic3ViIjoiVnFmbWNqOVdRdlJTOEJZQW9lZjJOZnhlSXVkMiIsImlhdCI6MTY2OTI4NDAwNCwiZXhwIjoxNjY5Mjg3NjA0LCJmaXJlYmFzZSI6eyJpZGVudGl0aWVzIjp7Imdvb2dsZS5jb20iOlsiMTExNTkxNzcwMTQ4MjcxOTc5NzYzIl19LCJzaWduX2luX3Byb3ZpZGVyIjoiZ29vZ2xlLmNvbSJ9fQ.R95hhSSQI-LEYgjJx9IQ-weuDIZRc7umxVURhdqWvii3pC67GZkPoXMT0QqnehBb4DB7TQyUN_AGbO_G34HlOJZ3g1L7_f_45zdnGodZdW0he4zrGaqNj59pe1oppyvnG9EwupXwjjP1p-ASMvxUJ5VW4_TvkwJx9nIyB3PHNuqvPEvg8eqHACdxQ4lrqJClPgxJoHvh9rLgQmPLbwGGMDBDH8DMSID1fum5qfwWHUrqDp87MGbe43566tb2rh7YBB0Lpb8LCR-SbkgugnyxSl4LY_2NvP2ozRRY5EtbbggYrW3akMaYNXq6abAJrIucf6GJzerL0tQW'
  end

  sequence :cm_random_phone_number do |n|
    "01234567#{n}#{n+1}"
  end

  factory :cm_user, class: Spree.user_class do
    email                 { generate(:random_email) }
    phone_number          { generate(:cm_random_phone_number) }
    login                 { email }
    password              { 'secret' }
    password_confirmation { password }
    authentication_token  { generate(:user_authentication_token) } if Spree.user_class.attribute_method? :authentication_token
    public_metadata { {} }
    private_metadata { {} }
  end

  factory :cm_user_id_token, class: Spree.user_class do
    to_create { |user| user.save(validate: false) }

    initialize_with do
      context = SpreeCmCommissioner::UserRegistrationWithIdToken.call(id_token: generate(:cm_id_token))
      context.user
    end
  end

  factory :cm_early_adopter_user, parent: :cm_user do
    spree_roles { [Spree::Role.find_by(name: 'early_adopter') || create(:role, name: 'early_adopter')] }
  end
end
