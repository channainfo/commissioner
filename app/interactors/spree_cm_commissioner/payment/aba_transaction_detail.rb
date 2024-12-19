require 'csv'

module SpreeCmCommissioner
  module Payment
    class AbaTransactionDetail < BaseInteractor
      delegate :input_csv_file, :combine_payment, to: :context
      # :user​​​, :is_from_backend, :user_deletion_reason_id, :optional_reason

      def call
        payment_numbers = []
        payment_blank_count = []
        # Open the destination CSV file for writing
        CSV.open(output_file, 'wb') do |csv_out|
          # Read from the source CSV file
          CSV.foreach(input_csv_file, headers: false) do |row|
            # Perform any modifications to the row here
            # For example, you can convert all names to uppercase:
            # row['Name'] = row['Name'].upcase if row['Name']

            # Write the row to the destination CSV
            transaction_detail = row[1]
            payment_number = extract_payment_number(transaction_detail)

            if payment_number.blank?
              payment_blank_count << transaction_detail
              next
            end

            payment_numbers << payment_number
            # output_row.insert(1, payment_number)
            ouput_row = [
              row[0],
              row[2],
              payment_number,
              row[1]
            ]
            csv_out << ouput_row
          end
        end


        File.write(output_arrays_file, payment_numbers.inspect) if context.respond_to?(:combine_payment)

        # p "payment_blank_count: #{payment_blank_count.inspect}"
        p "payment_blank_count: #{payment_blank_count.size}, payment_numbers #{payment_numbers.count}"
      end


      def output_arrays_file
        dir = File.dirname(input_csv_file)
        basename = File.basename(input_csv_file)

        File.join(dir, "output-array-#{basename}")
      end

      def output_file
        dir = File.dirname(input_csv_file)
        basename = File.basename(input_csv_file)

        File.join(dir, "output-csv-#{basename}")
      end

      # PAYMENT FROM SENG SOPHEA *** *** 997 PURCHASE# PUTQ82CV APV 104902 ORIGINAL AMOUNT 400.00 USD AT Hang Meas Mobile REF# 100FT33056686876 ON Aug 31, 2024 11:02 PM REMARK: NONUNICODE-
      # PAYMENT FROM Ros Sereivuthy 00010235118429 BANK ACLEDA Bank Plc. ORIGINAL AMOUNT 70.00 USD AT Hang Meas Mobile ON Sep 01, 2024 08:29 AM REMARK: |APV:690061|Purchase #:PG20QAS6|Remark:42450377243 | KHQR      REF# 100FT33057339909 TRAN# KHQR_2424508694686 HASH# 7ebe1a2c
      def extract_payment_number(detail)
        patterns = [
          /PURCHASE#(.*?)APV/,
          /Purchase #:(.*?)\|/
        ]

        result = nil

        patterns.each do |pattern|
          match = detail.match(pattern)
          next if match.nil?

          result = match[1].strip
          break
        end

        result
      end

    end
  end
end
