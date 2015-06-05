require 'spec_helper'
describe BookTag do
    let(:book) {FactoryGirl.create(:book, isbn: '111', title: 'Malgudi days')}
    let(:tag_1) {FactoryGirl.create(:tag, name: 'tag_one')}
    let(:tag_2) {FactoryGirl.create(:tag, name: 'tag_two')}
    let(:tag_3) {FactoryGirl.create(:tag, name: 'tag_three')}

  context '#add_tags' do
    it 'should add tags on book' do
      BookTag.add_tags([tag_1, tag_2], book)

      expect(book.book_tags.count).to eq(2)
      expect(book.book_tags.collect(&:tag_id)).to match_array([tag_1.id, tag_2.id])
    end

    context 'when tags are already present on a book' do
      it 'should not add tags' do
        book_tag1 = BookTag.create(book_id: book.id, tag_id: tag_1.id)
        book_tag1 = BookTag.create(book_id: book.id, tag_id: tag_2.id)

        expect(book.book_tags.count).to eq(2)
        expect(book.book_tags.collect(&:tag_id)).to match_array([tag_1.id, tag_2.id])

        BookTag.add_tags([tag_2, tag_3], book)

        book.reload
        expect(book.book_tags.count).to eq(3)
        expect(book.book_tags.collect(&:tag_id)).to match_array([tag_1.id, tag_2.id, tag_3.id])
      end
    end
  end
end