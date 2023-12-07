FactoryBot.define do
  factory :customer_notification, class: SpreeCmCommissioner::CustomerNotification do
    title { FFaker::Name.name }
    body { FFaker::LoremUA.paragraph }
    payload { { test: :payload_data } }
    url { FFaker::Internet.http_url }
    notification_type { 'promotion' }

    trait :with_feature_image do
      after(:build) do |customer_notification|
        image = SpreeCmCommissioner::FeatureImage.new
        image.viewable = customer_notification
        io = File.open(Rails.root.join('spec', 'support', 'assets', 'notification.png').to_s)
        filename = 'notification.png'
        image.attachment.attach(io: io, filename: filename)

        image.save!
      end
    end

  end

end