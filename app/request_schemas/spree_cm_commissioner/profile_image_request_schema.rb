module SpreeCmCommissioner
  class ProfileImageRequestSchema < ApplicationRequestSchema
    params do
      required(:url).filled(:string)
    end

    rule(:url) do
      key.failure(:invalid) unless value.starts_with?('https://') && URI::DEFAULT_PARSER.make_regexp =~ value
    end
  end
end
