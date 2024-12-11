module SpreeCmCommissioner
  class QueueItem
    attr_accessor :id, :status, :queued_at, :collection_reference, :document_reference

    def initialize(id:, status:, queued_at:, collection_reference:, document_reference:)
      @id = id
      @status = status
      @queued_at = queued_at
      @collection_reference = collection_reference
      @document_reference = document_reference
    end
  end
end
