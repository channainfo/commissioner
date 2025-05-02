module SpreeCmCommissioner
  class ApplicationJob < ::ApplicationJob
    queue_as :default

    around_perform :log_exceptions

    private

    def log_exceptions
      yield
    rescue StandardError => e
      CmAppLogger.log(
        label: "#{self.class.name} failed",
        data: {
          error_class: e.class.name,
          error_message: e.message,
          arguments: arguments.inspect,
          backtrace: e.backtrace&.first(5)&.join("\n")
        }
      )

      raise # Re-raise the exception to let Sidekiq handle retries or failure
    end
  end
end
