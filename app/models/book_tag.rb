class BookTag < ActiveRecord::Base
  has_one :book
  has_one :tag

  def self.add_tags(tags, book)
    book_tag_ids = BookTag.where(:book_id => book.id).map(&:tag_id)
    book_tags = Tag.find(book_tag_ids)
    (tags - book_tags).map do |tag|
      BookTag.create({ book_id: book.id, tag_id: tag.id})
    end
  end
end