require 'spec_helper'

describe 'Test VCR ', :vcr  do
  it 'Get responses from an api' do
    response = Net::HTTP.get_response(URI('https://jsonplaceholder.typicode.com/posts/1'))
    json_response = JSON.parse(response.body)
    expect(response.response.class).to eq Net::HTTPOK
    expect(json_response).to have_key('userId')
    expect(json_response).to have_key('title')
  end
end