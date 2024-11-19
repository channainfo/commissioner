module SpreeCmCommissioner
  class ImportCsvTemplateDownloader < BaseInteractor
    delegate :import_type, to: :context

    def call
      headers = case import_type
                when 'new_order'
                  initial_headers = %w[order_channel variant_sku email]
                  initial_headers + SpreeCmCommissioner::Guest.csv_importable_columns.map(&:to_s)
                when 'existing_order'
                  initial_headers = %w[order_number guest_id]
                  initial_headers + SpreeCmCommissioner::Guest.csv_importable_columns.map(&:to_s)
                else
                  raise ArgumentError, 'Invalid import type'
                end

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
