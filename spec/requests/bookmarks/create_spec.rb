require 'rails_helper'

describe 'POST /bookmarks' do
  it 'valid bookmark attributes' do
    post '/bookmarks', params: {
      bookmark: {
        url: 'http://localhost:3000',
        title: 'this is a title'
      }
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
    }

    # response should have HTTP Status 422 unprocessable entity
    expect(response.status).to eq(422)

    json = JSON.parse(response.body).deep_symbolize_keys
    expect(json[:url]).to eq(["can't be blank"])

    # no new bookmark is created
    expect(Bookmark.count).to eq(0)
  end
end