module SpreeCmCommissioner
  class GenerateGuestsCsv < BaseInteractor
    delegate :collection, :file_name, to: :context

    def call
      headers = ['Full Name', 'Date of Birth', 'Gender', 'Occupation', 'ID Card Type', 'Entry Type']

      CSV.open(file_name, 'w') do |csv|
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
