require 'test/helper'

class Admin::PostsControllerTest < ActionController::TestCase

  def test_should_generate_xml

    assert @typus_user.is_root?

    expected = <<-RAW
<?xml version="1.0" encoding="UTF-8"?>
<posts type="array">
  <post>
    <status>unpublished</status>
    <title>Owned by admin</title>
  </post>
  <post>
    <status>unpublished</status>
    <title>Owned by editor</title>
  </post>
  <post>
    <status>published</status>
    <title>Title One</title>
  </post>
  <post>
    <status>unpublished</status>
    <title>Title Two</title>
  </post>
</posts>
    RAW

    get :index, :format => 'xml'
    assert_equal expected, @response.body

  end

  def test_should_generate_csv

    assert @typus_user.is_root?

    expected = <<-RAW
Title,Status
Owned by admin,unpublished
Owned by editor,unpublished
Title One,published
Title Two,unpublished
     RAW

    get :index, :format => 'csv'
    assert_equal expected, @response.body

  end

end