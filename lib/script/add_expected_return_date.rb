class ExpeceptedReturnDate
  def self.add
    records = Record.all
    records.each do |record|
      record.expected_return_date = record.borrow_date + record.book_copy.book.return_days.days
      record.save
      Rails.logger.info "Excepted return date #{record.expected_return_date} is added for record #{record.id}'"
    end
  end
end