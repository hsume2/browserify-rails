require 'test_helper'

class BrowserifyTest < ActionController::IntegrationTest

  setup do
    Rails.application.assets.cache = nil

    FileUtils.cp(File.join(Rails.root, 'app/assets/javascripts/application.js.example'), File.join(Rails.root, 'app/assets/javascripts/application.js'))
    FileUtils.cp(File.join(Rails.root, 'app/assets/javascripts/foo.js.example'), File.join(Rails.root, 'app/assets/javascripts/foo.js'))
    FileUtils.cp(File.join(Rails.root, 'app/assets/javascripts/nested/index.js.example'), File.join(Rails.root, 'app/assets/javascripts/nested/index.js'))
  end

  test "asset pipeline should serve application.js" do
    expected_output = fixture("application.out.js")

    get "/assets/application.js"
    assert_response :success
    assert_match expected_output, @response.body
  end

  test "asset pipeline should serve foo.js" do
    expected_output = fixture("foo.out.js")

    get "/assets/foo.js"
    assert_response :success
    assert_match expected_output, @response.body
  end

  test "asset pipeline should regenerate application.js when foo.js changes" do
    expected_output = fixture("application.out.js")

    get "/assets/application.js"
    assert_response :success
    assert_match expected_output, @response.body

    # Ensure that Sprockets can detect the change to the file modification time
    sleep 1

    File.open(File.join(Rails.root, 'app/assets/javascripts/foo.js'), 'w+') do |f|
      f.puts "module.exports = function (n) { return n * 12 }"
    end
    expected_output = fixture("app_foo_changed.out.js")

    get "/assets/application.js"
    assert_response :success
    assert_match expected_output, @response.body
  end

  def fixture(filename)
    File.open(File.dirname(__FILE__)+"/fixtures/#{filename}").read
  end
end
