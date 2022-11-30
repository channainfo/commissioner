module JsonHelper
  def json_response_body
    @json_response_body ||= JSON.parse(response.body)
  end
end