require 'spec_helper'


def to_date date
  date.strftime("%Y%m%d")
end

describe Book do

  context 'validations' do
    context '#validate_presence_of' do
      it { is_expected.to validate_presence_of :isbn }
    end

    context '#has_many' do
      it { is_expected.to have_many(:book_copies) }
      it { is_expected.to have_many(:book_tags) }
    end

    context '#validates_uniqueness_of' do
      it 'should not create book with existing isbn'do
        book1 = FactoryGirl.create(:book, isbn:'111', title:'Malgudi days')
        book2 = FactoryGirl.build(:book, isbn:'111', title:'Java programming')

        expect(book1).to be_valid
        expect(book2).not_to be_valid
      end
    end
  end

  context '#search' do
    it 'should give empty array when no book present with title having search parameter' do
      FactoryGirl.create(:book, isbn:'111', title:'Malgudi days')
      FactoryGirl.create(:book, isbn:'112', title:'Java programming')
      expect(Book.search('the')).to eq([])
    end

    it 'should give book with title having search parameter' do
      FactoryGirl.create(:book, isbn:'111', title:'Malgudi days')
      book2 = FactoryGirl.create(:book, isbn:'112', title:'Java programming')
      book3 = FactoryGirl.create(:book, isbn:'113', title:'Ruby programming')
      expect(Book.search('programming')).to match_array([book2,book3])
    end

    it 'should give case-insensitive result book with title or author or isbn or tags or publisher having search parameter' do
      FactoryGirl.create(:book, isbn:'000', title:'Malgudi days')
      book1 = FactoryGirl.create(:book, isbn:'111', title:'Search_term days')
      book2 = FactoryGirl.create(:book, isbn:'112', title:'Java programming', author: 'Mr. Search_term')
      book3 = FactoryGirl.create(:book, isbn:'113', title:'Ruby programming', publisher: 'search_term publications')

      tag = FactoryGirl.create(:tag, name:"search_term tag")
      book4 = FactoryGirl.create(:book, isbn:'114', title:'Ruby programming')
      FactoryGirl.create(:book_tag, book_id: book4.id, tag_id: tag.id)

      expect(Book.search('search_term')).to match_array([book1, book2, book3, book4])
    end

  end

  context '#copy_available' do
    it 'should give book available, if book copy is available ' do
      book = FactoryGirl.create(:book)
      FactoryGirl.create(:book_copy, book: book, isbn: book.isbn)

      expect(book.copy_available?).to eq(true)
    end

    it 'should give book not available, if no book copy is available ' do
      book = FactoryGirl.create(:book)
      FactoryGirl.create(:book_copy, book: book, isbn: book.isbn, status: BookCopy::Status::ISSUED)

      expect(book.copy_available?).to eq(false)
    end

    it 'should give book not available, if no book copy is there ' do
      book = FactoryGirl.create(:book)

      expect(book.copy_available?).to eq(false)
    end
  end

  context '#sort_books' do
    it 'should sort given books by availability with in ascending order by title' do
      book1 = FactoryGirl.create(:book, isbn: 12345, title: 'XYZ')
      FactoryGirl.create(:book_copy, book: book1, isbn: book1.isbn)
      book2 = FactoryGirl.create(:book, isbn: 12347, title: 'XYZ')
      FactoryGirl.create(:book_copy, book: book2, isbn: book2.isbn, status: BookCopy::Status::ISSUED)
      book3 = FactoryGirl.create(:book, isbn: 12346, title: 'ABC')
      FactoryGirl.create(:book_copy, book: book3, isbn: book3.isbn)
      book4 = FactoryGirl.create(:book, isbn: 12348, title: 'ABC')
      FactoryGirl.create(:book_copy, book: book4, isbn: book4.isbn, status: BookCopy::Status::ISSUED)

      sorted_books = Book.sort_books(Book.all)
      expect(sorted_books['Available']).to match_array([book3,book1])
      expect(sorted_books['Not available']).to match_array([book4,book2])
    end
  end

  context '#update_expected_return_days' do
    it 'should not update book if no change in return days' do
      book1 = FactoryGirl.create(:book, isbn: 12345, title: 'The book', return_days:10)

      expect(book1).not_to receive(:book_copies)

      book1.update_expected_return_days 10
    end

    it 'should update book and records associated to it on change in return days' do
      book = FactoryGirl.create(:book, isbn: '12345', title: 'The book', return_days:10)
      book_copy = FactoryGirl.create(:book_copy, isbn: '12345', book_id: book.id)
      record = FactoryGirl.create(:record, book_copy_id: book_copy.id, borrow_date: Date.today, expected_return_date: Date.today + 10.days )

      expect(to_date(record.expected_return_date)).to eq(to_date(Date.today + 10.days))
      book.update_expected_return_days 5
      expect(to_date(record.reload.expected_return_date)).to eq(to_date(Date.today + 5.days))
    end

  end

  context '#number_of_copies' do
    it 'should give number of copies' do
      book = FactoryGirl.create(:book, isbn: 12345, title: 'the book title')
      FactoryGirl.create(:book_copy, book: book, isbn: book.isbn)
      FactoryGirl.create(:book_copy, book: book, isbn: book.isbn)
      expect(book.number_of_copies).to eq(2)
    end
  end

  context '#create_copies' do
    it 'should create given number of copies' do
      book = FactoryGirl.create(:book, isbn: 1234, title: 'XYZ')
      book_copy_1 = {book: book, isbn: '1234', copy_id: '1'}
      book_copy_2 = {book: book, isbn: '1234', copy_id: '2'}

      book_copies = book.create_copies(2)
      expect(book_copies.count).to eq(2)
      compare(book_copies, [book_copy_1, book_copy_2])
    end

    def compare(actual_book_copies, expected_book_copies)
      (actual_book_copies - expected_book_copies).count == 0
    end
  end

  context '#add_tags' do
    it 'should create tags and add on book' do
      book = FactoryGirl.create(:book, isbn: 1234, title: 'XYZ')
      one = FactoryGirl.create(:tag, name: 'one')
      two = FactoryGirl.create(:tag, name: 'two')
      three = FactoryGirl.create(:tag, name: 'three')

      expect(Tag).to receive(:create_tags).with(%w(one two three)).and_return [one, two, three]

      book.add_tags('one two three')
      expect(book.tags).to eq([one, two, three])
    end
  end

  context '#update_tags' do
    it 'should create tags and add on book' do
      book = FactoryGirl.create(:book, isbn: 1234, title: 'XYZ')
      one = FactoryGirl.create(:tag, name: 'one')
      two = FactoryGirl.create(:tag, name: 'two')
      three = FactoryGirl.create(:tag, name: 'three')

      expect(Tag).to receive(:create_tags).with(%w(one two three)).and_return [one, two, three]

      book.update_tags('one two three')
      expect(book.tags).to eq([one, two, three])
    end

    it 'should delete old tags' do
      book = FactoryGirl.create(:book, isbn: 1234, title: 'XYZ')
      one = FactoryGirl.create(:tag, name: 'one')
      two = FactoryGirl.create(:tag, name: 'two')
      three = FactoryGirl.create(:tag, name: 'three')

      book.tags = [three]

      expect(Tag).to receive(:create_tags).with(%w(one two)).and_return [one, two]

      book.update_tags('one two')
      expect(book.tags).to eq([one, two])
    end
  end
end