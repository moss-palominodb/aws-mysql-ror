require 'test_helper'

class AwsControllerTest < ActionController::TestCase
  test "should get regions" do
    get :regions
    assert_response :success
  end

  test "should get region" do
    get :region
    assert_response :success
  end

end
