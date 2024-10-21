module SpreeCmCommissioner
  class GuestIdCardManager < IdCardManager
    def guestable
      @guestable ||= SpreeCmCommissioner::Guest.find(context.guestable_id)
    end
  end
end
