require 'test_base'

class UserApiTest < ActionDispatch::IntegrationTest
  test '401 not login' do
    get '/api/users/me'
    assert_response 401
  end

  test '200 logined' do
    u = users(:one)
    post "/api/users/#{u.id}/login"
    get '/api/users/me'
    assert_response 200
  end
end