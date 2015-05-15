FactoryGirl.define  do
  factory :book_copy, class: BookCopy do |f|
    book_id 1
    isbn "123456789"
    status "available"
  end
end
