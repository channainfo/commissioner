module SpreeCmCommissioner
  module ApplicationJobDecorator
    def self.prepended(base)
      base.discard_on ActiveJob::DeserializationError do |job, error|
        handle_deserialization_error(job, error)
      end

      def self.handle_deserialization_error(job, error)
        label = "#{job.class}: #{error.message}"
        data = job.as_json

        CmAppLogger.log(label:, data:)
      end
    end
  end
end

ApplicationJob.prepend(SpreeCmCommissioner::ApplicationJobDecorator)
