require 'spec_helper'
require 'csv'
require 'tempfile'

RSpec.describe SpreeCmCommissioner::Exports::ExportGuestCsvService do
  let(:export_id) { 1 }
  let(:tempfile) { Tempfile.new(['test', '.csv']) }
  let(:export) { double(SpreeCmCommissioner::Exports::ExportGuestCsv, file_path: tempfile.path, file_name: 'test.csv') }
  let(:exported_file) { double('ExportedFile') }
  let(:service) { described_class.new(export_id) }
  let(:guest1) { create(:guest, preferences: nil) }
  let(:guest2) { create(:guest, preferences: nil) }
  let(:scope) { double }

  before do
    allow(SpreeCmCommissioner::Exports::ExportGuestCsv).to receive(:find).with(export_id).and_return(export)
    allow(export).to receive(:construct_header).and_return(SpreeCmCommissioner::Guest.csv_importable_columns)
    allow(export).to receive(:scope).and_return(scope)
    allow(export).to receive(:exported_file).and_return(exported_file)
    allow(exported_file).to receive(:attach)
    allow(scope).to receive(:find_each).and_yield(guest1).and_yield(guest2)
  end

  after do
    tempfile.close
    tempfile.unlink
  end

  describe '#call' do
    before do
      allow(export).to receive(:construct_row).with(instance_of(SpreeCmCommissioner::Guest)).and_return(guest1.attributes.values, guest2.attributes.values)
    end

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
    before do
      allow(export).to receive(:construct_row).with(instance_of(SpreeCmCommissioner::Guest)).and_return(guest1.attributes.values, guest2.attributes.values)
    end

    it 'creates a csv file with correct content' do
      service.generate_csv_file

      expect(File.exist?(export.file_path)).to be true

      csv_content = CSV.read(export.file_path)

      expected_content = [
        export.construct_header.map(&:to_s),
        guest1.attributes.values.map { |value| value.nil? ? nil : value.to_s },
        guest2.attributes.values.map { |value| value.nil? ? nil : value.to_s }
      ]

      expect(csv_content).to eq(expected_content)
    end
  end

  describe '#attach_csv_file' do
    before do
      allow(File).to receive(:open).with(export.file_path).and_return(tempfile)
    end

    it 'attaches the csv file to the export' do
      service.attach_csv_file

      expect(File).to have_received(:open).with(export.file_path)
      expect(export.exported_file).to have_received(:attach).with(io: tempfile, filename: export.file_name)
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
