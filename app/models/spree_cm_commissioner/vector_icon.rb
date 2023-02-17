module SpreeCmCommissioner
  class VectorIcon
    include ActiveModel::Validations
    attr_accessor :set_name, :icon_name, :path

    validates :path, presence: true
    validates :set_name, presence: true
    validates :icon_name, presence: true

    # path: no-icon/backend-arrow-up.svg
    #
    # set_name: backend
    # icon_name: arrow-up
    def initialize(attributes = {})
      path = attributes[:path]

      name = File.basename(path)
      set_name = name.split('-')[0]
      icon_name = name.delete_prefix("#{set_name}-").delete_suffix('.svg')

      send('path=', path)
      send('set_name=', set_name)
      send('icon_name=', icon_name)
    end
  end
end
