module SpreeCmCommissioner
  class GenerateGuestsCsvJob
    include Sidekiq::Job
    include Sidekiq::Status::Worker

    sidekiq_options retry: 0

    def perform(guest_ids, csv_file_path)
      headers = ['Full Name', 'Date of Birth', 'Gender', 'Occupation', 'ID Card Type', 'Entry Type']
      collection = SpreeCmCommissioner::Guest.where(id: guest_ids)

      CSV.open(csv_file_path, 'w') do |csv|
        csv << headers

        collection.find_each do |guest|
          entry_type_key = SpreeCmCommissioner::CheckIn.entry_types.key(guest.entry_type)
          csv << [
            guest.full_name,
            guest.dob&.strftime('%d %b %Y'),
            guest.gender&.titleize,
            guest.other_occupation&.titleize || guest.occupation&.name,
            guest.id_card&.card_type&.titleize,
            entry_type_key ? entry_type_key.titleize : nil
          ]
        end
      end
    end
  end
end
