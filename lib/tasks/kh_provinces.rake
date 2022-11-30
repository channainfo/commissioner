namespace :data do
  desc "Seeds provinces"
  task seed_kh_provinces: :environment do
    cambodia = Spree::Country.find_or_initialize_by(iso_name: 'CAMBODIA', iso: 'KH', iso3: 'KHM', name: 'Cambodia', numcode: 116, states_required: false)
    states = [
      { name: 'Phnom Penh', abbr: 'PP' },
      { name: 'Siemreap', abbr: 'SR' },
      { name: 'Battambang', abbr: 'BB' },
      { name: 'Preah Sihanouk', abbr: 'SV' },
      { name: 'Kep', abbr: 'KE' },
      { name: 'Kampot', abbr: 'KP' },
      { name: 'Koh Kong', abbr: 'KK' },
      { name: 'Mondul Kiri', abbr: 'MK' },
      { name: 'Ratanak Kiri', abbr: 'RK' },
      { name: 'Banteay Meanchey', abbr: 'BM' },
      { name: 'Kampong Cham', abbr: 'KC' },
      { name: 'Kampong Chhnang', abbr: 'KN' },
      { name: 'Kampong Speu', abbr: 'KS' },
      { name: 'Kampong Thom', abbr: 'KT' },
      { name: 'Kandal', abbr: 'KD' },
      { name: 'Kratie', abbr: 'KR' },
      { name: 'Preah Vihear', abbr: 'PR' },
      { name: 'Prey Veng', abbr: 'PV' },
      { name: 'Pursat', abbr: 'PS' },
      { name: 'Stung Treng', abbr: 'ST' },
      { name: 'Svay Rieng', abbr: 'SG' },
      { name: 'Takeo', abbr: 'TK' },
      { name: 'Oddar Meanchey', abbr: 'OM' },
      { name: 'Pailin', abbr: 'P' },
      { name: 'Tboung Khmum', abbr: 'TBK' }
    ]
    states.each { |state| cambodia.states.find_or_initialize_by(state) }
    cambodia.save

    p "Created #{cambodia.states.count} provinces"
  end
end