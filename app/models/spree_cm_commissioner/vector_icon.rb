module SpreeCmCommissioner
  class VectorIcon
    include ActiveModel::Validations
    attr_accessor :set_name, :icon_name, :path

    ACCEPTED_EXTENSIONS = %w[.svg .png].freeze
    TYPES = %w[cm backend payment_methods].freeze

    validates :path, presence: true
    validates :set_name, presence: true
    validates :icon_name, presence: true

    # path: no-icon/backend-arrow-up.svg
    #
    # set_name: backend
    # icon_name: arrow-up
    def initialize(attributes = {})
      path = attributes[:path]

      name = File.basename(path, '.*')
      set_name = name.split('-')[0]
      icon_name = name.delete_prefix("#{set_name}-")

      send('path=', path)
      send('set_name=', set_name)
      send('icon_name=', icon_name)
    end

    def self.search(path_prefix:, extension:, query:)
      icons = all

      icons = icons.filter { |icon| icon.path.start_with?(path_prefix) } unless path_prefix.nil?
      icons = icons.filter { |icon| icon.path.end_with?(extension) } unless extension.nil?
      icons = icons.filter { |icon| query.in? icon.path } unless query.nil?

      Kaminari.paginate_array(icons)
    end

    def self.all
      @all ||= asset_files.filter_map do |path|
        SpreeCmCommissioner::VectorIcon.new(path: path) if path.end_with?(*ACCEPTED_EXTENSIONS)
      end
    end

    # rails assets:precompile
    def self.asset_files
      @asset_files ||= Rails.application.assets_manifest.assets.keys
    end
  end
end
