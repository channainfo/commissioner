FactoryBot.define do
  factory :export_guest_csv, class: SpreeCmCommissioner::Exports::ExportGuestCsv do |f|
    f.name { 'guest-csv'}
    f.file_name { 'guest-csv.csv' }
    f.file_path { 'tmp/guest-csv.csv' }
    f.export_type { 'SpreeCmCommissioner::Exports::ExportGuestCsv' }
    f.status { 0 }
  end
end
