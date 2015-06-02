require 'spec_helper'
describe BookTag do
  context '#add_tags' do

    let (:book) { FactoryGirl.create(:book, isbn:'111', title:'Malgudi days') }
    let (:tags) { Tag.create_tags(%w(one two three)) }

    it 'should add tags on book' do
      saved_book_tags = BookTag.add_tags(tags, book)

      expect(saved_book_tags.count).to eq 3
      expect(BookTag.all).to match_array saved_book_tags
    end

    context 'when tags are already present on a book' do

      before do
        BookTag.add_tags(tags, book)
      end

      it 'should not add tags' do
        saved_book_tags = BookTag.add_tags(tags, book)

        expect(saved_book_tags).to be_empty
      end
    end
  end
end