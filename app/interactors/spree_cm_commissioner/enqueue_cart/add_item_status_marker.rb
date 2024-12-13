require 'google/cloud/firestore'

module SpreeCmCommissioner
  module EnqueueCart
    class AddItemStatusMarker < BaseInteractor
      delegate :order_number, :job_id, :status, :queued_at, :variant_id, :quantity, to: :context

      def call
        if order_number.nil? || job_id.nil? || status.nil?
          context.fail!(message: 'Missing required fields')
          return
        end
        update_cart_firestore_status

        assign_firestore_context_attributes
      end

      def update_cart_firestore_status
        data_to_set = build_data_to_set

        firestore_reference.set(data_to_set, merge: true)
      end

      def current_date
        Time.current.strftime('%Y-%m-%d')
      end

      def build_data_to_set
        {
          status: status,
          queued_at: queued_at.presence,
          variant_id: variant_id.presence,
          quantity: quantity.presence
        }.compact
      end

      def assign_firestore_context_attributes
        document = firestore_reference.get

        context.firestore_status = document[:status]
        context.firestore_queued_at = document[:queued_at]
        context.firestore_document_reference = document.ref.path.split('/documents').last
        context.firestore_collection_reference = context.firestore_document_reference.rpartition('/').first
      end

      private

      def firestore_reference
        firestore.col('queues')
                 .doc('cart')
                 .col(current_date)
                 .doc(order_number)
                 .col('records')
                 .doc(job_id)
      end

      def firestore
        @firestore ||= Google::Cloud::Firestore.new(project_id: service_account[:project_id], credentials: service_account)
      end

      def service_account
        @service_account ||= Rails.application.credentials.cloud_firestore_service_account
      end
    end
  end
end
