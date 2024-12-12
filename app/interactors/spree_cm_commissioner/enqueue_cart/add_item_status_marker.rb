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

        FirestoreClient.instance
                       .col('queues')
                       .doc('cart')
                       .col(order_number)
                       .doc(job_id)
                       .set(data_to_set, merge: true)
      end

      def build_data_to_set
        {
          status: status,
          queued_at: queued_at.presence,
          variant_id: variant_id.presence,
          quantity: quantity.presence
        }.compact
      end

      def firestore_object
        FirestoreClient.instance.col('queues').doc('cart').col(order_number).doc(job_id).get
      end

      def firestore_status
        firestore_object[:status]
      end

      def firestore_queued_at
        firestore_object[:queued_at]
      end

      def firestore_collection_reference
        firestore_object.ref.path
      end

      def firestore_document_reference
        firestore_collection_reference.split('/documents').last
      end

      def assign_firestore_context_attributes
        document = firestore_object

        context.firestore_status = document[:status]
        context.firestore_queued_at = document[:queued_at]
        context.firestore_collection_reference = document.ref.path
        context.firestore_document_reference = document.ref.path.split('/documents').last
      end
    end
  end
end
