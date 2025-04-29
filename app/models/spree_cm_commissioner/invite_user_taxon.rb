module SpreeCmCommissioner
  class InviteUserTaxon < SpreeCmCommissioner::Base
    belongs_to :user_taxon, class_name: 'SpreeCmCommissioner::UserTaxon'
    belongs_to :invite, class_name: 'SpreeCmCommissioner::Invite'
    has_one :inviter, class_name: 'Spree::User', through: :invite
    after_create :send_crew_invite_email

    def send_crew_invite_email
      SpreeCmCommissioner::CrewInviteMailer.send_crew_invite_email(id).deliver_later
    end
  end
end
