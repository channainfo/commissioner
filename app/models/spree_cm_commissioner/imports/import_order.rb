module SpreeCmCommissioner
  module Imports
    class ImportOrder < Import
      enum import_type: { :new_order => 0, :existing_order => 1 }
      preference :fail_rows, :string
    end
  end
end
