module SpreeCmCommissioner
  class OrderParamsChecker
    def self.process_paid_params(params)
      q_params = (params[:q].presence || {})
      q_params[:completed_at_lteq] = q_params[:completed_at_lteq].to_date.end_of_day if q_params[:completed_at_lteq].present?
      q_params
    end

    def self.process_balance_due_params(params)
      q_params = (params[:q].presence || {})
      q_params[:created_at_lteq] = q_params[:created_at_lteq].to_date.end_of_day if q_params[:created_at_lteq].present?
      q_params
    end
  end
end
