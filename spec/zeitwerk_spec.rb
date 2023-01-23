require 'spec_helper'

describe 'Zeitwerk' do
  it 'eager loads all files' do
    expect { Zeitwerk::Loader.eager_load_all }.to_not raise_error
  end
end
