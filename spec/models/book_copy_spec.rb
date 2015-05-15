require 'spec_helper'

describe BookCopy do
  context "validations" do
    context '#has_many' do
      it { is_expected.to have_many(:records) }
    end

    context 'associations' do
      it { is_expected.to belong_to :book }
    end

    context 'before_create' do
      it 'should create book when book_id present in book table' do
        book = FactoryGirl.create(:book, isbn: '111', title: 'Malgudi days')
        book_copy = FactoryGirl.create(:book_copy, isbn: '111', book_id: book.id)

        expect(book_copy).to be_valid
      end

      it 'should not create book when book_id does not present in book table' do
        book_copy = FactoryGirl.build(:book_copy, isbn: '111', book_id: 10)

        expect(book_copy.save).to be(false)
      end
    end

    context '#issue' do
      it 'should change status of book copy and create record' do
        user_id = 1
        book = FactoryGirl.create(:book, isbn: '111', title: 'Malgudi days')
        book_copy = FactoryGirl.create(:book_copy, isbn: '111', book_id: book.id)

        expect(Record).to receive(:create).with({user_id: user_id, book_copy_id: book_copy.id, borrow_date: Date.today})

        book_copy.issue user_id

        expect(book_copy.reload.status).to eq('Issued')
      end
    end
  end
end
