module SpreeCmCommissioner
  class InviteUserEvent < InviteUserTaxon
    alias_attribute :user_event, :user_taxon
  end
end
