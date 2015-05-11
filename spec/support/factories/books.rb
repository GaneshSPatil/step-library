FactoryGirl.define  do
  factory :book, class: Book do |f|
    isbn "123456789"
    title "Book Title"
    author "Book Author"
  end
end
