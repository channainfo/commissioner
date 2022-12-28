module SpreeCmCommissioner
  module DashCaseName
    extend ActiveSupport::Concern

    included do
      # DASH_CASE_REGEX = /\A^[a-z0-9-]*\z/
      # validates_format_of :name, with: DASH_CASE_REGEX, message: "only dash-case"
      
      before_validation :convert_name_to_dash_case
    end

    def convert_name_to_dash_case
      self.name = self.name.underscore.parameterize.dasherize unless self.name.nil?
    end
  end
end
