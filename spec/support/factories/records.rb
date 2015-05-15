FactoryGirl.define  do
  factory :record, class: Record do |f|
    user_id 1
    book_copy_id 1
    borrow_date Date.today
  end

end