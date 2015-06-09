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

    it 'should not give disabled user in search results' do
      enabled_user = FactoryGirl.create(:user, name: 'Suraj Babar', email: 'suraj@bab.com', enabled: true)
      disabled_user = FactoryGirl.create(:user, name: 'Suraj Gunjal', email: 'digi@gun.com', enabled: false)
      users = User.search('Suraj')
      expect(users).to match_array([enabled_user])
    end

    it 'should give user in ascending order by name' do
      suraj = FactoryGirl.create(:user, name: 'Suraj Babar', email: 'suraj@bab.com')
      digvijay = FactoryGirl.create(:user, name: 'Digvijay Gunjal', email: 'digi@gun.com')
      users = User.search ''
      expect(users.map { |u| u.attributes.except('created_at', 'updated_at')}).to eq([digvijay, suraj].map { |u| u.attributes.except('created_at', 'updated_at')})
    end

  end

  context '#disabled' do
    it 'should give disabled users with name having in search parameter' do
      suraj = FactoryGirl.create(:user, name: 'Suraj Babar', email: 'suraj@bab.com', enabled: false)
      digvijay = FactoryGirl.create(:user, name: 'Digvijay Gunjal', email: 'digi@gun.com', enabled: false)

      actual = User.disabled('suraj')
      expect(actual).to eq([suraj])
    end

    it 'should give empty array when user is not present' do
      users = User.disabled('not a user name')
      expect(users).to be_empty
    end

    it 'should give empty array when searched disabled user name does not match with any user name' do
      FactoryGirl.create(:user, name: 'Suraj Babar', email: 'suraj@bab.com', enabled: false)
      FactoryGirl.create(:user, name: 'Digvijay Gunjal', email: 'digi@gun.com', enabled: false)
      users = User.disabled('sumit')
      expect(users).to be_empty
    end

    it 'should not give enabled user in search results' do
      enabled_user = FactoryGirl.create(:user, name: 'Suraj Babar', email: 'enabled@exp.com', enabled: true)
      disabled_user = FactoryGirl.create(:user, name: 'Suraj Gunjal', email: 'disabled@exp.com', enabled: false)
      users = User.disabled('Suraj')
      expect(users).to match_array([disabled_user])
    end

    it 'should give disabled user in ascending order by name' do
      suraj = FactoryGirl.create(:user, name: 'Suraj Babar', email: 'suraj@bab.com', enabled: false)
      digvijay = FactoryGirl.create(:user, name: 'Digvijay Gunjal', email: 'digi@gun.com', enabled: false)
      users = User.disabled ''
      expect(users.map { |u| u.attributes.except('created_at', 'updated_at')}).to eq([digvijay, suraj].map { |u| u.attributes.except('created_at', 'updated_at')})
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

  context '#issued_books_records' do

    context 'when user has not borrowed books' do
      it 'should give empty array ' do
        user = FactoryGirl.create(:user)

        expect(user.issued_books_records).to eq([])
      end
    end

    context 'when user has borrowed books' do
      it 'should give list of issued books records of users' do
        user = FactoryGirl.create(:user)
        book1 = FactoryGirl.create(:book, isbn: '111', title: 'Malgudi days')
        book2 = FactoryGirl.create(:book, isbn: '112', title: 'The Guide')
        book_copy_1 = FactoryGirl.create(:book_copy, isbn: book1.isbn, book_id: book1.id)
        book_copy_2 = FactoryGirl.create(:book_copy, isbn: book2.isbn, book_id: book2.id)
        record1 = FactoryGirl.create(:record, user_id: user.id, book_copy_id: book_copy_1.id)
        record2 = FactoryGirl.create(:record, user_id: user.id, book_copy_id: book_copy_2.id)

        expect(user.issued_books_records).to match_array([record1, record2])
      end
    end

    context 'when multiple users have borrowed books' do
      it 'should give issued books records of particular user' do
        user1 = FactoryGirl.create(:user, email: 'Suraj@email.com')
        user2 = FactoryGirl.create(:user, email: 'Digvijay@email.com')

        book1 = FactoryGirl.create(:book, isbn: '111', title: 'The Guide')
        book2 = FactoryGirl.create(:book, isbn: '112', title: 'Malgudi days')
        book_copy_1 = FactoryGirl.create(:book_copy, isbn: book1.isbn, book_id: book1.id)
        book_copy_2 = FactoryGirl.create(:book_copy, isbn: book2.isbn, book_id: book2.id)

        record1 = FactoryGirl.create(:record, user_id: user1.id, book_copy_id: book_copy_1.id)
        record2 = FactoryGirl.create(:record, user_id: user2.id, book_copy_id: book_copy_2.id)

        expect(user1.issued_books_records).to match_array([record1])
        expect(user2.issued_books_records).to match_array([record2])
      end
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

  context "#is_disabled" do
    context "should give the status of the existing user" do
      it "who is enabled" do
        uid123 = 123
        auth123 = Auth.new uid123
        FactoryGirl.create(:user, enabled: true, uid: uid123)
        expect(User.is_disabled auth123).to be false
      end

      it "who is disabled" do
        uid234 = 234
        auth234 = Auth.new uid234
        FactoryGirl.create(:user, enabled: false, uid: uid234)
        expect(User.is_disabled auth234).to be true
      end
    end

    context "should give the status of the new user" do
      it "as enabled" do
        uid234 = 234
        auth234 = Auth.new uid234
        expect(User.is_disabled auth234).to be false
      end
    end
  end

  context '#disable' do
    it 'should disable user' do
      suraj = FactoryGirl.create(:user, name: 'Suraj Babar', email: 'suraj@bab.com', uid: '456')
      suraj.disable

      expect(User.is_disabled Auth.new '456').to be true
    end
  end

end