class AddNationalityDataToTaxons < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.test?

    nationalities_taxonomy = Spree::Store.default.taxonomies.where(name: 'Nationalities', kind: Spree::Taxon.kinds[:nationality]).first_or_create

    nationalities_data = YAML.load_file(Rails.root.join('config', 'data', 'nationalities.yml'))
    nationalities_list = nationalities_data['nationalities']

    nationalities_list.each do |nationality, country_code|
      taxon = nationalities_taxonomy.taxons.where(
        name: nationality,
        subtitle: country_code,
        parent_id: nationalities_taxonomy.root,
        kind: Spree::Taxon.kinds[:nationality]
      ).first_or_create

      puts "Seeded nationality: #{nationality}" if taxon.persisted?
    end
  end
end
