require 'spec_helper'

describe User do
  context '#associations' do
    it { is_expected.to have_many(:records) }
  end

  context '#search' do
    it 'should give users with name having in search parameter' do
      suraj = FactoryGirl.create(:user, name: 'Suraj Babar', email: 'suraj@bab.com',)
      digvijay = FactoryGirl.create(:user, name: 'Digvijay Gunjal', email: 'digi@gun.com')

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
      FactoryGirl.create(:user, name: 'Suraj Babar', email: 'suraj@bab.com')
      FactoryGirl.create(:user, name: 'Digvijay Gunjal', email: 'digi@gun.com')
      users = User.search('sumit')
      expect(users).to be_empty
    end
  end

  context '#books' do

    it 'should give empty array when no book is borrowed by user' do
      user = FactoryGirl.create(:user)

      expect(user.books).to eq([])
    end

    it 'should give list of book borrowed by users' do
      user = FactoryGirl.create(:user)
      book1 = FactoryGirl.create(:book, isbn: '111', title: 'Malgudi days')
      book2 = FactoryGirl.create(:book, isbn: '112', title: 'The Guide')
      book_copy_1 = FactoryGirl.create(:book_copy, isbn: book1.isbn, book_id: book1.id)
      book_copy_2 = FactoryGirl.create(:book_copy, isbn: book2.isbn, book_id: book2.id)
      record1 = FactoryGirl.create(:record, user_id: user.id, book_copy_id: book_copy_1.id)
      record2 = FactoryGirl.create(:record, user_id: user.id, book_copy_id: book_copy_2.id)

      expect(user.books).to match_array([book1, book2])
    end

    it 'should give all books of particular user' do
      user1 = FactoryGirl.create(:user, email: 'Suraj@email.com')
      user2 = FactoryGirl.create(:user, email: 'Digvijay@email.com')

      book1 = FactoryGirl.create(:book, isbn: '111', title: 'The Guide')
      book2 = FactoryGirl.create(:book, isbn: '112', title: 'Malgudi days')
      book_copy_1 = FactoryGirl.create(:book_copy, isbn: book1.isbn, book_id: book1.id)
      book_copy_2 = FactoryGirl.create(:book_copy, isbn: book2.isbn, book_id: book2.id)

      record1 = FactoryGirl.create(:record, user_id: user1.id, book_copy_id: book_copy_1.id)
      record2 = FactoryGirl.create(:record, user_id: user2.id, book_copy_id: book_copy_2.id)

      expect(user1.books).to match_array([book1])
      expect(user2.books).to match_array([book2])
    end
  end

  context '#book_copies' do

    it 'should give empty array when no book copies are borrowed by user' do
      user = FactoryGirl.create(:user)

      expect(user.book_copies).to eq([])
    end

    it 'should give list of book copies borrowed by users' do
      user = FactoryGirl.create(:user)
      book1 = FactoryGirl.create(:book, isbn: '111', title: 'Malgudi days')
      book2 = FactoryGirl.create(:book, isbn: '112', title: 'The Guide')
      book_copy_1 = FactoryGirl.create(:book_copy, isbn: book1.isbn, book_id: book1.id)
      book_copy_2 = FactoryGirl.create(:book_copy, isbn: book2.isbn, book_id: book2.id)
      record1 = FactoryGirl.create(:record, user_id: user.id, book_copy_id: book_copy_1.id)
      record2 = FactoryGirl.create(:record, user_id: user.id, book_copy_id: book_copy_2.id)

      expect(user.book_copies).to match_array([book_copy_1, book_copy_2])
    end

    it 'should give all books copy of particular user' do
      user1 = FactoryGirl.create(:user, email: 'Suraj@email.com')
      user2 = FactoryGirl.create(:user, email: 'Digvijay@email.com')

      book1 = FactoryGirl.create(:book, isbn: '111', title: 'The Guide')
      book2 = FactoryGirl.create(:book, isbn: '112', title: 'Malgudi days')
      book_copy_1 = FactoryGirl.create(:book_copy, isbn: book1.isbn, book_id: book1.id)
      book_copy_2 = FactoryGirl.create(:book_copy, isbn: book2.isbn, book_id: book2.id)

      record1 = FactoryGirl.create(:record, user_id: user1.id, book_copy_id: book_copy_1.id)
      record2 = FactoryGirl.create(:record, user_id: user2.id, book_copy_id: book_copy_2.id)

      expect(user1.book_copies).to match_array([book_copy_1])
      expect(user2.book_copies).to match_array([book_copy_2])
    end
  end

  context '#has_book?' do

    it 'should give false if user dont have book' do
      user1 = FactoryGirl.create(:user)
      book1 = FactoryGirl.create(:book, isbn: '111', title: 'The Guide')

      allow_any_instance_of(User).to receive(:books).and_return([])

      expect(user1.has_book? book1).to be(false)
    end

    it 'should give false if no book copy available' do
      user1 = FactoryGirl.create(:user)
      book1 = FactoryGirl.create(:book, isbn: '111', title: 'The Guide')
      book2 = FactoryGirl.create(:book, isbn: '112', title: 'Malgudi days')

      allow_any_instance_of(User).to receive(:books).and_return([book1, book2])

      expect(user1.has_book? book1).to be(true)
    end
  end

  context '#return_book' do

    it 'should return the book and update the return date' do
      user = FactoryGirl.create(:user)
      book = FactoryGirl.create(:book, isbn: '111', title: 'The Guide')
      book_copy = FactoryGirl.create(:book_copy, isbn: book.isbn , book_id: book.id)
      record = FactoryGirl.create(:record, user_id: user.id, book_copy_id: book_copy.id)
      expect(user.book_copies).to match_array([book_copy])

      user.return_book book_copy.id

      expect(user.book_copies).to match_array([])
    end
  end

end