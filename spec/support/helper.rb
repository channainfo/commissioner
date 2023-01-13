require 'terminal-table'

module Helper
  def json_response_body
    @json_response_body ||= JSON.parse(response.body)
  end

  def date(str)
    # '2023_01_01' or '2023-01-01'
    str.gsub('_','').to_date
  end

  def print_as_table(records, fields = [])
    records = records.to_a
    return if records.blank?

    record = records.first
    # get attributes if record is activerecord
    header_keys = record.respond_to?(:attribute_names) ? record.attribute_names : record.keys
    header_keys = fields.present? ? fields : header_keys

    rows = [ header_keys ]
    records.each do |r|
      rows << header_keys.map { |key| r[key.to_s] || r[key.to_sym] }
    end

    puts Terminal::Table.new(rows: rows)
  end
end