module SpreeCmCommissioner
  class StateJob < ApplicationJob
    def perform(state_id)
      state = ::Spree::State.find_by(id: state_id)
      StateUpdater.call(state: state)
    end
  end
end
