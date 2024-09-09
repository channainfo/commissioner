module SpreeCmCommissioner
  class StateUpdater < BaseInteractor
    delegate :state, to: :context

    def call
      state.update_total_inventory
    end
  end
end
