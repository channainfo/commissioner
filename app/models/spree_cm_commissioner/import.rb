module SpreeCmCommissioner
  class Import < Base
    enum status: { :queue => 0, :progress => 1, :done => 2, :failed => 3 }
    has_one_attached :imported_file
  end
end
