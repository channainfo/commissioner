module SpreeCmCommissioner
  class AccountDeletion < BaseInteractor
    delegate :is_from_backend, to: :context
    # :user​​​, :is_from_backend, :user_deletion_reason_id, :optional_reason

    def call
      save_survey unless is_from_backend
      destroy_user
    end

    def save_survey
      survey = SpreeCmCommissioner::UserDeletionSurvey.new(
        user_id: context.user.id,
        user_deletion_reason_id: context.user_deletion_reason_id,
        optional_reason: context.optional_reason
      )

      return if survey.save

      context.fail!(message: survey.errors.full_messages.to_sentence)
    end

    def destroy_user
      context.user.update(account_deletion_at: Time.current)
    end
  end
end
