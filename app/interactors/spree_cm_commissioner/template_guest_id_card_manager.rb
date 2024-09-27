module SpreeCmCommissioner
  class TemplateGuestIdCardManager < IdCardManager
    def guestable
      @guestable ||= SpreeCmCommissioner::TemplateGuest.find(context.guestable_id)
    end
  end
end
