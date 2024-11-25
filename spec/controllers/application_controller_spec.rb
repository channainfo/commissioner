require 'spec_helper'

RSpec.describe ApplicationController do
  controller do
    def index
      head :ok
    end
  end

  describe 'set_cache_control_for_cdn' do
    context 'max age is defined' do
      it 'set the cache controller header for cdn with the value' do
        ENV['CONTENT_CACHE_MAX_AGE'] = '120'

        get :index

        expect(response).to have_http_status(:ok)
        expect(response.headers['Pragma']).to eq('no-cache')
        expect(response.headers['Expires']).to eq('0')
        expect(response.headers['Cache-Control']).to eq('max-age=0, public, s-maxage=120')
      end
    end

    context 'max age is not defined' do
      it 'set the cache controller header for cdn with a default value 180' do
        ENV['CONTENT_CACHE_MAX_AGE'] = nil

        get :index

        expect(response).to have_http_status(:ok)
        expect(response.headers['Pragma']).to eq('no-cache')
        expect(response.headers['Expires']).to eq('0')
        expect(response.headers['Cache-Control']).to eq('max-age=0, public, s-maxage=180')
      end
    end
  end
end