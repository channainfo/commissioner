FactoryBot.define do
  factory :invite, class: SpreeCmCommissioner::Invite do
    token { SecureRandom.hex(16) }
    taxon { create(:taxon) }
    inviter { create(:user) }
  end
end
