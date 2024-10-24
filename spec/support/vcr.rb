VCR.configure do |config|
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into :webmock
  config.ignore_localhost = true
  config.configure_rspec_metadata!

  # Filter sensitive data such as API keys
  config.filter_sensitive_data('<OPENAI_API_KEY>') { ENV['OPENAI_API_KEY'] }

  # Optional: Filter sensitive headers (e.g., Authorization tokens)
  config.filter_sensitive_data('<AUTHORIZATION_TOKEN>') do |interaction|
    interaction.request.headers['Authorization'].first if interaction.request.headers['Authorization']
  end
end