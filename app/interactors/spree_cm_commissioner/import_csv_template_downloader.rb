module SpreeCmCommissioner
  class ImportCsvTemplateDownloader < BaseInteractor
    delegate :import_type, to: :context

    def call
      require_headers = case import_type
                        when 'new_order'
                          %w[order_channel order_email order_phone_number variant_sku]
                        when 'existing_order'
                          %w[order_number order_channel order_email order_phone_number]
                        else
                          raise ArgumentError, 'Invalid import type'
                        end

      guest_attributes = SpreeCmCommissioner::Guest.csv_importable_columns
      headers = require_headers + guest_attributes

      filename = 'import_order_csv_template.csv'
      filepath = Rails.root.join('tmp', filename)

      CSV.open(filepath, 'w') do |csv|
        csv << headers
      end

      context.filename = filename
      context.filepath = filepath
    end
  end
end
