module SpreeCmCommissioner
  class OrderCompleteNotification < NoticedFcmBase
    def notificable
      order
    end

    def order
      params[:order]
    end
  end
end
