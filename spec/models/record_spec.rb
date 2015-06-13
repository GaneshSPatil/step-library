require 'spec_helper'
describe Record do
  context '#associations' do
    it { is_expected.to belong_to :book_copy }
    it { is_expected.to belong_to :user }
  end

  context '#book' do
    it 'should return book associated with record' do
      user = FactoryGirl.create(:user)

      book = FactoryGirl.create(:book, isbn: 12345, title: 'the book title')
      book_copy = FactoryGirl.create(:book_copy, book: book, isbn: book.isbn, copy_id: "#{book.id}-1")
      record = FactoryGirl.create(:record, user_id:user.id, book_copy_id: book_copy.id)

      expect(record.book_title).to eq(book.title)
    end
  end

  context '#book_copy_id' do
    it 'should return book copy id associated with record' do
      user = FactoryGirl.create(:user)

      book = FactoryGirl.create(:book, isbn: 12345, title: 'the book title')
      book_copy = FactoryGirl.create(:book_copy, book: book, isbn: book.isbn, copy_id: "#{book.id}-1")
      record = FactoryGirl.create(:record, user_id:user.id, book_copy_id: book_copy.id)

      expect(record.book_copy_id).to eq(book_copy.copy_id)
    end
  end

  context '#overdue?' do
    it "should give true if record is overdue than expected return date" do
      yesterday = Time.now - 1.days
      book = FactoryGirl.create(:book, isbn: 12345, title: 'the book title')
      book_copy = FactoryGirl.create(:book_copy, book: book, isbn: book.isbn, copy_id: "#{book.id}-1")
      record = FactoryGirl.create(:record, book_copy: book_copy, expected_return_date: yesterday)

      expect(record.overdue?).to be(true)
    end
    it "should give false if record is not overdue" do
      tomorrow = Time.now + 1.days
      book = FactoryGirl.create(:book, isbn: 12345, title: 'the book title')
      book_copy = FactoryGirl.create(:book_copy, book: book, isbn: book.isbn, copy_id: "#{book.id}-1")
      record = FactoryGirl.create(:record, book_copy: book_copy, expected_return_date: tomorrow)

      expect(record.overdue?).to be(false)
    end
  end


end