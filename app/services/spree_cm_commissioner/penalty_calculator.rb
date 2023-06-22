module SpreeCmCommissioner
  class PenaltyCalculator
    def self.calculate_penalty_in_days(current_date, due_date)
      ((current_date - due_date).to_i / 1.day).to_i
    end
  end
end
