require 'spec_helper'

describe User do

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
end