require 'rails_helper'

describe 'PUT /bookmarks' do
  let!(:bookmark) { Bookmark.create(url: 'http://localhost:3000', title: 'Demo title') }

  # create a user before tests are run
  let!(:user) { User.create(username: 'demo_user', authentication_token: 'abcdef') }

  it 'valid bookmark atttributes' do
    # send put request
    put "/bookmarks/#{bookmark.id}", params: {
      bookmark: {
        url: 'http://localhost:5000',
        title: 'Another title'
      }
    }, headers: {
      'X-Username': user.username,
      'X-Token': user.authentication_token
    }

    # response should have HTTP Status 200 Ok
    expect(response.status).to eq(200)

    # response should contain JSON of the updated object
    json = JSON.parse(response.body).deep_symbolize_keys
    expect(json[:url]).to eq('http://localhost:5000')
    expect(json[:title]).to eq('Another title')

    # the bookmark title and url should be updated
    expect(bookmark.reload.title).to eq('Another title')
    expect(bookmark.reload.url).to eq('http://localhost:5000')
  end

  it 'invalid bookmark attributes' do
    put "/bookmarks/#{bookmark.id}", params: {
      bookmark: {
        url: '',
        title: 'Another title'
      }
    }, headers: {
      'X-Username': user.username,
      'X-Token': user.authentication_token
    }

    # response should have HTTP Status 422 Unprocessable entity
    expect(response.status).to eq(422)

    # response should contain the error message
    json = JSON.parse(response.body).deep_symbolize_keys
    expect(json[:url]).to eq(["can't be blank"])

    # the bookmark title and url remain unchanged
    expect(bookmark.reload.title).to eq('Demo title')
    expect(bookmark.reload.url).to eq('http://localhost:3000')
  end
end