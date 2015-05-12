require 'rails_helper'

describe UsersController do

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
    end

    context "when user is not Admin" do
      before {
        @user = User.create(:role => 'Intern')
        sign_in :user, @user
      }

      it "should respond with 404" do
        expect(User).not_to receive(:search)
        get :index
        expect(response).not_to be_success
        expect(response).to have_http_status(404)
      end

    end
  end
end
