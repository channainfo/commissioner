module SpreeCmCommissioner
  class UserEvent < UserTaxon
    alias_attribute :event, :taxon
  end
end
