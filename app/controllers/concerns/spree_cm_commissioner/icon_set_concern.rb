module SpreeCmCommissioner
  module IconSetConcern
    extend ActiveSupport::Concern

    def icon_objects
      backend_icon_objects + commissioner_icon_objects
    end

    def backend_icon_objects
      @backend_icon_objects ||= backend_icons.map do |path|
        SpreeCmCommissioner::VectorIcon.new(path: path)
      end
    end

    def commissioner_icon_objects
      @commissioner_icon_objects ||= commissioner_icons.map do |path|
        SpreeCmCommissioner::VectorIcon.new(path: path)
      end
    end

    def backend_icons
      @backend_icons ||= asset_files.select do |file_name|
        file_name.start_with?('backend-')
      end
    end

    def commissioner_icons
      @commissioner_icons ||= asset_files.select do |file_name|
        file_name.start_with?('cm-')
      end
    end

    def asset_files
      Rails.application.assets_manifest.assets.keys
    end
  end
end
