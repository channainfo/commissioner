module SpreeCmCommissioner
  class TemplateGuest < SpreeCmCommissioner::Base
    acts_as_paranoid

    enum :gender, { :other => 0, :male => 1, :female => 2 }

    has_one :id_card, as: :id_cardable, class_name: 'SpreeCmCommissioner::IdCard', dependent: :destroy

    belongs_to :user, class_name: 'Spree::User'
    belongs_to :occupation, class_name: 'Spree::Taxon'
    belongs_to :nationality, class_name: 'Spree::Taxon'

    before_save :ensure_single_default

    private

    def ensure_single_default
      return unless is_default && is_default_changed?

      user.template_guests.where.not(id: id).find_each do |template_guest|
        template_guest.update!(is_default: false)
      end
    end
  end
end
