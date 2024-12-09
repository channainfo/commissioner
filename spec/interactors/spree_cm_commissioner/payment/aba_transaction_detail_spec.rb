require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Payment::AbaTransactionDetail do
  let(:features) { '../../../../fixtures' }

  let(:input_t1) { File.expand_path("#{features}/payment/t1.csv", __FILE__) }
  let(:hm_test1) { File.expand_path("#{features}/payment/hm-test1.csv", __FILE__) }
  let(:hm_test2) { File.expand_path("#{features}/payment/hm-test2.csv", __FILE__) }

  # 69 + 1162 = 1,231
  describe '.call' do
    it 'generate output csv' do
      # described_class.call(input_csv_file: input_t1, combine_payment: true)
      #
      # described_class.call(input_csv_file: hm_test1, combine_payment: true)
      described_class.call(input_csv_file: hm_test2, combine_payment: true)
    end
  end

  describe '#extract_payment_number' do
    subject { described_class.new }

    it 'return valid payment nubmer from the transaction details via online payment' do
      payment_detail = 'PAYMENT FROM SENG SOPHEA *** *** 997 PURCHASE# PUTQ82CV APV 104902 ORIGINAL AMOUNT 400.00 USD AT Hang Meas Mobile REF# 100FT33056686876 ON Aug 31, 2024 11:02 PM REMARK: NONUNICODE-'
      result = subject.send(:extract_payment_number, payment_detail)

      expect(result).to eq 'PUTQ82CV'
    end

    it 'return valid payment nubmer from the transaction details via online payment' do
      payment_detail = 'PAYMENT FROM Ros Sereivuthy 00010235118429 BANK ACLEDA Bank Plc. ORIGINAL AMOUNT 70.00 USD AT Hang Meas Mobile ON Sep 01, 2024 08:29 AM REMARK: |APV:690061|Purchase #:PG20QAS6|Remark:42450377243 | KHQR      REF# 100FT33057339909 TRAN# KHQR_2424508694686 HASH# 7ebe1a2c'
      result = subject.send(:extract_payment_number, payment_detail)

      expect(result).to eq 'PG20QAS6'
    end
  end

  describe '#output_file' do
    subject { described_class.new(input_csv_file: input_t1) }

    it 'return output file' do
      result = subject.send(:output_file)

      expect(result).to include('/spec/fixtures/payment/output-csv-t1.csv')
    end
  end

  describe '#output_arrays_file' do
    subject { described_class.new(input_csv_file: input_t1) }

    it 'return output file' do
      result = subject.send(:output_arrays_file)

      expect(result).to include('/spec/fixtures/payment/output-array-t1.csv')
    end
  end
end