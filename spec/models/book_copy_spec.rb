require 'rails_helper'

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
    end
  end
end
