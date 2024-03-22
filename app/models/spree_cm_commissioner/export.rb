module SpreeCmCommissioner
  class Export < Base
    before_create :set_uuid
    has_one_attached :exported_file

    enum status: { :queue => 0, :progress => 1, :done => 2, :failed => 3 }

    def export_columns
      raise 'You must implement export_columns method in your sub class'
    end

    def construct_row(_resource)
      raise 'You must implement export_rows method in your sub class'
    end

    def scope
      raise 'You must implement scope method in your sub class'
    end

    def set_uuid
      self.uuid = SecureRandom.uuid
    end

    def export_csv
      SpreeCmCommissioner::ExportCsvJob.perform_async(id)
    end
  end
end
