module SpreeCmCommissioner
  class CrewInvite < Invite
    def confirm(invitee_id)
      SpreeCmCommissioner::CrewInviter.call(id: id, invitee_id: invitee_id)
    end
  end
end
