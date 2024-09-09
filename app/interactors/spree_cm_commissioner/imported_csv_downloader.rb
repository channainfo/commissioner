module SpreeCmCommissioner
  class ImportedCsvDownloader < BaseInteractor
    def call
      import_order = SpreeCmCommissioner::Imports::ImportOrder.find(context.import_order_id)

      if import_order.imported_file.attached?
        context.file_data = import_order.imported_file.download
        context.filename = import_order.imported_file.filename.to_s
        context.content_type = import_order.imported_file.content_type
      else
        context.fail!(error: 'No file attached')
      end
    end
  end
end
