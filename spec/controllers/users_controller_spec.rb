require 'rails_helper'

describe UsersController do
  before{
    allow_any_instance_of(ApplicationController).to receive(:authenticate_user!)
  }
  context "#index" do
    context "when user is Admin" do
      before {
        @user = User.create(:role => 'Admin')
        sign_in :user, @user
      }

      it "should respond with success" do
        expect(User).not_to receive(:search)
        get :index
        expect(response).to be_success
        expect(response).to have_http_status(200)
      end

      it "should return users with matching substring" do
        expect(User).to receive(:search).with('dummy')

        params = {:search => 'dummy'}
        get :index, params

        expect(response).to be_success
        expect(response).to have_http_status(200)

      end

      it "should remove extra spaces and return users with matching substring" do
        expect(User).to receive(:search).with('dummy')
        allow_any_instance_of(String).to receive(:squish).and_return('dummy')

        params = {:search => '  dummy  '}
        get :index, params

        expect(response).to be_success
        expect(response).to have_http_status(200)

      end
    end

    context "when user is not Admin" do
      before {
        @user = User.create(:role => 'Intern')
        sign_in :user, @user
      }

      it "should respond with 403" do
        expect(User).not_to receive(:search)
        get :index
        expect(response).not_to be_success
        expect(response).to have_http_status(403)
      end
    end
  end

  context "#books" do

    it "should give list of books borrowed by user" do
      user = FactoryGirl.create(:user)
      book = FactoryGirl.create(:book, isbn: '111', title: 'Malgudi days')
      book_copy = FactoryGirl.create(:book_copy, isbn: '111', book_id: book.id)
      record = FactoryGirl.create(:record, user_id: user.id, book_copy_id: book_copy.id)

      sign_in :user, user
      get :books

      expect(response).to have_http_status(200)
      expect(response).to be_success
    end
  end

  context '#show' do
    before {
      @user = FactoryGirl.create(:user, :admin)
      allow_any_instance_of(UsersController).to receive(:current_user).and_return(@user)
    }

    it 'should give details of user with books he has borrowed' do

      expect_any_instance_of(User).to receive(:books).and_return([])
      get :show, {id: @user.id}

      expect(response).to have_http_status(200)
      expect(response).to be_success
    end
  end
end
