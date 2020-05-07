require 'test_helper'

class TestBase < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    Rails.application
  end
end