require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @people = User.new
  end

  def test_name_is_towonzhou
    assert_equal "1988", current_user.id
  end
end
