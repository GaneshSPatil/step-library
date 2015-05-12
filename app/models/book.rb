class Book < ActiveRecord::Base

  def self.search(search_string)
    Book.select { |book| book.title.downcase.include?(search_string.downcase) }
  end

  def self.order_by(field_name)
    Book.order(field_name)
  end

end
