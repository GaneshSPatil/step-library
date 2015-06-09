class BookCopyId
  def self.change_to_string
    book_copies = BookCopy.all
    book_copies.each do |book_copy|
      book_copy.copy_id ="#{book_copy.book_id}-#{book_copy.copy_id}"

      book_copy.save
      Rails.logger.info "Copy id for #{book_copy.id} change to '#{book_copy.book_id}-#{book_copy.copy_id}'"
    end
  end
end