require 'rails_helper'

describe ErrorsController do
  before {
    allow_any_instance_of(ApplicationController).to receive(:authenticate_user!)
  }

  describe 'GET #file_not_found' do
    it 'returns http success' do
      get :file_not_found
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #forbidden_access_denied' do
    it 'returns http success' do
      get :forbidden_access_denied
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #internal_server_error' do
    it 'returns http success' do
      get :internal_server_error
      expect(response).to have_http_status(:success)
    end
  end

end
