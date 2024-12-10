require 'google/cloud/firestore'

module SpreeCmCommissioner
  module Cart
    class AddItemStatusMarker < BaseInteractor
      delegate :order_number, :job_id, :status, :queued_at, :complete_at, to: :context

      def call
        if order_number.nil? || job_id.nil? || status.nil?
          context.fail!(message: 'Missing required fields')
          return
        end
        update_cart_firestore_status
      end

      def firestore
        @firestore ||= Google::Cloud::Firestore.new(project_id: service_account[:project_id], credentials: service_account)
      end

      def service_account
        @service_account ||= Rails.application.credentials.cloud_firestore_service_account
      end

      def update_cart_firestore_status
        data_to_set = build_data_to_set

        firestore.col('queues')
                 .doc('cart')
                 .col(order_number)
                 .doc(job_id)
                 .set(data_to_set, merge: true)
      end

      def build_data_to_set
        {
          status: status,
          queued_at: queued_at.presence
        }.compact
      end
    end
  end
end
