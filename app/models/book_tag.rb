class BookTag < ActiveRecord::Base
  has_one :book
  has_one :tag

  def self.add_tags(tags, book)
    tags.each {|tag|
      BookTag.find_or_create_by(book_id: book.id, tag_id: tag.id)
    }
  end
end