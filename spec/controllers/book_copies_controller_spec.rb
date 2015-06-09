require 'spec_helper'

describe BookCopiesController do
  before {
    allow_any_instance_of(ApplicationController).to receive(:authenticate_user!)
  }

  context '#logs' do
    it 'should respond with success' do
      allow_any_instance_of(ApplicationController).to receive(:authenticate_admin)

      book = FactoryGirl.create(:book)
      book_copy = FactoryGirl.create(:book_copy, isbn: book.isbn, book_id:book.id, copy_id: "#{book.id}-1")

      params = {:id => book_copy.copy_id}
      get :logs, params

      expect(response).to be_success
    end
  end
end