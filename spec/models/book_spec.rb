require 'spec_helper'

describe Book do

  context "validations" do
    context '#validate_presence_of' do
      it { is_expected.to validate_presence_of :isbn }
    end

    context '#has_many' do
      it { is_expected.to have_many(:book_copies) }
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
      book1 = FactoryGirl.create(:book, isbn:'111', title:'Malgudi days')
      book2 = FactoryGirl.create(:book, isbn:'112', title:'Java programming')
      book3 = FactoryGirl.create(:book, isbn:'113', title:'Ruby programming')
      expect(Book.search('programming')).to match_array([book2,book3])
    end
  end

  context '#order_by_title' do
    it 'should give book with title in ascending order' do

      book1 = FactoryGirl.create(:book, isbn:'111', title:'Malgudi days')
      book2 = FactoryGirl.create(:book, isbn:'112', title:'Java programming')
      book3 = FactoryGirl.create(:book, isbn:'113', title:'Ruby programming')

      expect(Book.order_by('title')).to eq([book2,book1,book3])
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
      FactoryGirl.create(:book_copy, book: book, isbn: book.isbn, status: BookCopy::Status::ISSUED);

      expect(book.copy_available?).to eq(false)
    end

    it 'should give book not available, if no book copy is there ' do
      book = FactoryGirl.create(:book)

      expect(book.copy_available?).to eq(false)
    end
  end
end