module SpreeCmCommissioner
  class RecaptchaTokenValidator < BaseInteractor
    RECAPTCHA_MINIMUM_SCORE = 0.5

    delegate :token, :action, :site_key, to: :context

    def call
      context.response = create_assessment
      check_score
    end

    def create_assessment
      event = {
        parent: "projects/#{project_id}",
        assessment: { event: { site_key: site_key, token: token } }
      }

      client.create_assessment(event)
    rescue StandardError
      context.fail!(message: I18n.t('recaptcha.request_failed'))
    end

    def check_score
      unless context.response.token_properties.valid
        context.fail!(message: context.response.token_properties.invalid_reason.presence || I18n.t('recaptcha.invalid_code'))
      end

      context.fail!(message: I18n.t('recaptcha.score_not_qualify')) unless context.response.risk_analysis.score > RECAPTCHA_MINIMUM_SCORE
      context.fail!(message: I18n.t('recaptcha.action_not_matched')) unless context.response.token_properties.action == action
    end

    def project_id
      context.project_id ||= Rails.application.credentials.google_service_account[:project_id]
    end

    def client
      context.client ||= ::Google::Cloud::RecaptchaEnterprise.recaptcha_enterprise_service
    end
  end
end
