module SpreeCmCommissioner
  class InviteUserTaxon < SpreeCmCommissioner::Base
    belongs_to :user_taxon, class_name: 'SpreeCmCommissioner::UserTaxon'
    belongs_to :invite, class_name: 'SpreeCmCommissioner::Invite'
  end
end
