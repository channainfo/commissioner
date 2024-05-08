module SpreeCmCommissioner
  class ImportCsvTemplateDownloader < BaseInteractor
    def call
      filename = 'import_order_csv_template.csv'
      filepath = Rails.root.join('tmp', filename)
      require_headers = %w[order_channel order_email order_phone_number variant_id]
      guest_attributes = SpreeCmCommissioner::Guest.csv_importable_columns - [:id]

      headers = require_headers + guest_attributes

      CSV.open(filepath, 'w') do |csv|
        csv << headers
      end

      context.filename = filename
      context.filepath = filepath
    end
  end
end
