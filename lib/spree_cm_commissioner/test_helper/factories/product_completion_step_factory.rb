FactoryBot.define do
  factory :cm_product_completion_step, class: SpreeCmCommissioner::ProductCompletionStep do
    title { 'Must complete this step' }
    description { 'Click link now to complete' }
    action_label { 'Link' }

    factory :cm_chatrace_tg_product_completion_step, class: SpreeCmCommissioner::ProductCompletionSteps::ChatraceTelegram do
      preferred_entry_point_link { 'https://t.me/ThePlatformKHBot?start=bookmeplus' }
    end
  end
end
