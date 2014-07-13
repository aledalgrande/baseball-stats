require 'csv'

module CSVImport
  extend ActiveSupport::Concern

  module ClassMethods
    def import_csv(filename)
      CSV.foreach(filename, headers: true, row_sep: :auto) do |row|
        db_options = { upsert: true, new: true }
        yield(row, db_options)
      end
    end
  end
end