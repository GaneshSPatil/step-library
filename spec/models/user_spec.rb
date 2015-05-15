require 'spec_helper'

describe User do
  context '#associations'do
    it { is_expected.to have_many(:records) }
  end

  context '#search' do
    it 'should give users with name having in search parameter' do
      suraj = FactoryGirl.create(:user, name:'Suraj Babar', email: 'suraj@bab.com',)
      digvijay = FactoryGirl.create(:user, name:'Digvijay Gunjal', email: 'digi@gun.com')

      actual = User.search('suraj')
      expected = [suraj]
      expect(actual).to match_array(expected)
      expect(digvijay).not_to be_in(actual)
    end

    it 'should give empty array when user is not present' do
      users = User.search('not a user name')
      expect(users).to be_empty
    end

    it 'should give empty array when searched user name does not match with any user name' do
      FactoryGirl.create(:user, name:'Suraj Babar', email: 'suraj@bab.com')
      FactoryGirl.create(:user, name:'Digvijay Gunjal', email: 'digi@gun.com')
      users = User.search('sumit')
      expect(users).to be_empty
    end
  end

  context '#books' do

    it 'should give empty array when no book is borrowed by user' do
      user = FactoryGirl.create(:user)

      expect(user.books).to eq([])
    end

    it 'should give list of books borrowed by users' do
      user = FactoryGirl.create(:user)
      book1 = FactoryGirl.create(:book, isbn: '111', title: 'Malgudi days')
      book2 = FactoryGirl.create(:book, isbn: '112', title: 'The Guide')
      book_copy_1 = FactoryGirl.create(:book_copy, isbn: book1.isbn, book_id: book1.id)
      book_copy_2 = FactoryGirl.create(:book_copy, isbn: book2.isbn, book_id: book2.id)
      record1 = FactoryGirl.create(:record, user_id: user.id, book_copy_id: book_copy_1.id)
      record2 = FactoryGirl.create(:record, user_id: user.id, book_copy_id: book_copy_2.id)

      expect(user.books).to match_array([book1,book2])
    end

    it 'should give ' do
      user1 = FactoryGirl.create(:user, email:'Suraj@email.com')
      user2 = FactoryGirl.create(:user, email:'Digvijay@email.com')

      book1 = FactoryGirl.create(:book, isbn: '111', title: 'The Guide')
      book2 = FactoryGirl.create(:book, isbn: '112', title: 'Malgudi days')
      book_copy_1 = FactoryGirl.create(:book_copy, isbn: book1.isbn, book_id: book1.id)
      book_copy_2 = FactoryGirl.create(:book_copy, isbn: book2.isbn, book_id: book2.id)

      record1 = FactoryGirl.create(:record, user_id: user1.id, book_copy_id: book_copy_1.id)
      record2 = FactoryGirl.create(:record, user_id: user2.id, book_copy_id: book_copy_2.id)

      expect(user1.books).to match_array([book1])
    end
  end
end