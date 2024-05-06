require 'spec_helper'
require 'csv'

RSpec.describe SpreeCmCommissioner::Exports::ExportGuestCsvService do
  let(:export_id) { 1 }
  let(:export) { double(SpreeCmCommissioner::Exports::ExportGuestCsv, file_path: 'tmp/test.csv', file_name: 'test.csv') }
  let(:exported_file) { double('ExportedFile') }
  let(:service) { described_class.new(export_id) }
  let(:resource) { double }
  let(:scope) { double }

  before do
    allow(SpreeCmCommissioner::Exports::ExportGuestCsv).to receive(:find).with(export_id).and_return(export)
    allow(export).to receive(:construct_header).and_return(['header1', 'header2'])
    allow(export).to receive(:construct_row).with(resource).and_return(['data1', 'data2'])
    allow(export).to receive(:scope).and_return(scope)
    allow(export).to receive(:exported_file).and_return(exported_file)
    allow(exported_file).to receive(:attach)
    allow(scope).to receive(:find_each).and_yield(resource)
  end

  after do
    File.delete(export.file_path) if File.exist?(export.file_path)
  end

  describe '#call' do
    it 'updates export status to progress, generates csv file, and updates export status to done' do
      expect(service).to receive(:update_export_status_when_start)
      expect(service).to receive(:generate_csv_file)
      expect(service).to receive(:update_export_status_when_finish).with(:done)

      service.call
    end

    it 'updates export status to failed when an error occurs' do
      allow(service).to receive(:generate_csv_file).and_raise(StandardError)

      expect(service).to receive(:update_export_status_when_start)
      expect(service).to receive(:update_export_status_when_finish).with(:failed)

      expect { service.call }.to raise_error(StandardError)
    end
  end

  describe '#generate_csv_file' do
    it 'creates a csv file with correct content' do
      service.generate_csv_file

      expect(File.exist?(export.file_path)).to be true

      csv_content = CSV.read(export.file_path)
      expect(csv_content).to eq([export.construct_header, export.construct_row(resource)])
    end
  end

  describe '#update_export_status_when_start' do
    it 'updates export status to progress and sets the started_at time' do
      expect(export).to receive(:update).with(status: :progress, started_at: anything)

      service.update_export_status_when_start
    end
  end

  describe '#update_export_status_when_finish' do
    it 'updates export status and sets the started_at time' do
      expect(export).to receive(:update).with(status: :done, finished_at: anything)

      service.update_export_status_when_finish(:done)
    end
  end
end
