module SpreeCmCommissioner
  module IconSetConcern
    extend ActiveSupport::Concern

    def icon_objects
      backend_icon_objects + commissioner_icon_objects
    end

    def backend_icon_objects
      @backend_icon_objects ||= backend_icons.map { |path|
        SpreeCmCommissioner::VectorIcon.new(
          path: path.split("app/assets/images/")[1],
        )
      }
    end

    def commissioner_icon_objects
      @commissioner_icon_objects ||= commissioner_icons.map { |path| 
        SpreeCmCommissioner::VectorIcon.new(
          path: path.split("app/assets/images/")[1],
        )
      }
    end

    def backend_icons
      @backend_icons ||= asset_files.select { 
        |file_name| File.basename(file_name).start_with?("backend-") 
      }
    end

    def commissioner_icons
      @commissioner_icons ||= asset_files.select { 
        |file_name| File.basename(file_name).start_with?("cm-")
      }
    end

    def asset_files
      @asset_files ||= Rails.application.assets.each_file.select {
        |file_name| "assets/images".in?(file_name) and file_name.end_with?(".svg")
      }
    end
  end
end
