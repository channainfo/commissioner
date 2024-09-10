module SpreeCmCommissioner
  class ImportCsvTemplateDownloader < BaseInteractor
    delegate :import_type, to: :context

    def call
      headers = case import_type
                when 'new_order'
                  %w[order_channel variant_sku email phone_number first_name last_name]
                when 'existing_order'
                  %w[order_number phone_number first_name last_name]
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
