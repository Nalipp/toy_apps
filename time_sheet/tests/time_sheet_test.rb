ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"

require_relative "../time_sheet.rb"

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_index_redirect
    get "/"
    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_equal 200, last_response.status
  end

  def test_timesheets
    get "/timesheets"
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "Time sheets"
    assert_includes last_response.body, "+"
  end

  def test_create_new_timesheet
    get "/timesheet/new"
    assert_equal 200, last_response.status
    assert_includes last_response.body, "Add timesheet"
    assert_includes last_response.body, "create</button>"
  end

  def test_post_new_timesheet_displays_on_timesheets
    post "/timesheet/new", timesheet_name: "new content"
    assert_equal 302, last_response.status

    get "/timesheets"
    assert_equal 200, last_response.status
    assert_includes last_response.body, "new content"
  end

  def test_validate_for_empty_data
    post "/timesheet/new", timesheet_name: ""
    assert_equal 200, last_response.status
    assert_includes last_response.body, "Inputs must be between 1 and 100 characters"
  end

  def test_validate_for_too_many_characters
    post "/timesheet/new", timesheet_name: "!"*101
    assert_equal 200, last_response.status
    assert_includes last_response.body, "Inputs must be between 1 and 100 characters"
  end

  def test_get_timesheet_by_id
    post "/timesheet/new", timesheet_id: 1, timesheet_name: "new content"
    assert_equal 302, last_response.status

    get "/timesheet/1"
    assert_equal 200, last_response.status
    assert_includes last_response.body, "new content"
  end

  def test_edit_timesheet
    post "/timesheet/new", timesheet_id: 1, timesheet_name: "new content"
    assert_equal 302, last_response.status

    get "/timesheet/1/edit"
    assert_equal 200, last_response.status

    post "/timesheet/1/edit", timesheet_name: "new name"
    assert_equal 302, last_response.status

    get "/timesheet/1"
    assert_equal 200, last_response.status
    assert_includes last_response.body, "new name"
  end

  def test_destroy_timesheet
    post "/timesheet/new", timesheet_id: 1, timesheet_name: "new content"
    assert_equal 302, last_response.status

    post "/timesheet/1/destroy"
    assert_equal 302, last_response.status

    get "/timesheets"
    assert_equal 200, last_response.status
    refute_includes last_response.body, "new content"
  end


end
