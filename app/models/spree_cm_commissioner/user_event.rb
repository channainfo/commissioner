module SpreeCmCommissioner
  class UserEvent < UserTaxon
    alias_attribute :event, :taxon
    validates :taxon_id, uniqueness: { scope: :user_id, message: 'and User relatoinship is already existed.' } # rubocop:disable Rails/I18nLocaleTexts
  end
end
