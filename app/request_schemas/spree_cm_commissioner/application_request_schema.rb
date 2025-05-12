module SpreeCmCommissioner
  class ApplicationRequestSchema < Dry::Validation::Contract
    config.messages.load_paths << Pathname.new("#{COMMISSIONER_ROOT}/config/locales/dry_validations.en.yml")

    option :request

    delegate :success?, :errors, to: :result

    def output
      result.to_h
    end

    def error_message
      errors.map { |error| "#{error.path.join(', ')}: #{error.text}" }.to_sentence
    end

    private

    def result
      @result ||= call(input_params)
    end

    def input_params
      request.params
    end
  end
end
