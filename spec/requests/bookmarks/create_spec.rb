require 'rails_helper'

describe 'POST /bookmarks' do
  
  # group scenarios with authenticated user into this context block
  context 'authenticated user' do
    # create a user before tests are run
    let!(:user) { User.create(username: 'demo_user', authentication_token: 'abcdef') }

    # pass the user username and authentication token to the header
    it 'valid bookmark attributes' do
      post '/bookmarks', params: {
        bookmark: {
          url: 'http://localhost:3000',
          title: 'this is a title'
        }
      }, headers: {
        'X-Username': user.username,
        'X-Token': user.authentication_token
      }

      # response should have status HTTP Status 201 Created
      expect(response.status).to eq(201)

      json = JSON.parse(response.body).deep_symbolize_keys

      # check value of the returned response hash
      expect(json[:url]).to eq('http://localhost:3000')
      expect(json[:title]).to eq('this is a title')

      # 1 new bookmark record is created
      expect(Bookmark.count).to eq(1)

      # check latest record data
      expect(Bookmark.last.title).to eq('this is a title')
    end

    it 'invalid bookmark attributes' do
      post '/bookmarks', params: {
        bookmark: {
          url: '',
          title: 'this is a title'
        }
      }, headers: {
        'X-Username': user.username,
        'X-Token': user.authentication_token
      }

      # response should have HTTP Status 422 unprocessable entity
      expect(response.status).to eq(422)

      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json[:url]).to eq(["can't be blank"])

      # no new bookmark is created
      expect(Bookmark.count).to eq(0)
    end
  end

  context 'unauthenticated user' do
    it 'should return forbidden error' do
      post '/bookmarks', params: {
        bookmark: {
          url: 'http://localhost:3000',
          title: 'this is a title'
        }
      }

      # response should have HTTP status 403 Forbidden
      expect(response.status).to eq(403)

      # expect response to contain an error message
      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json[:message]).to eq('Invalid user')
    end
  end
end