module SpreeCmCommissioner
  module ParameterizeName
    extend ActiveSupport::Concern

    included do
      # DASH_CASE_REGEX = /\A^[a-z0-9_-]*\z/
      # validates_format_of :name, with: DASH_CASE_REGEX, message: "only lowercase with underscore or dash"

      before_validation :convert_name_to_paramaterize
    end

    def convert_name_to_paramaterize
      self.name = self.name.parameterize unless self.name.nil?
    end
  end
end
