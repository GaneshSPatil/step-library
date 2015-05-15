require 'rails_helper'
describe Record do
  context '#associations' do
    it { is_expected.to belong_to :book_copy }
    it { is_expected.to belong_to :user }
  end
end