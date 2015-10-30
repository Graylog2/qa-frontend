require "test/unit"
require "json"
require "selenium-webdriver"
require "base64"

class Test::Unit::TestCase
  def setup
    if not ENV['SUT']
      raise "Define target system by setting 'SUT' environment variable"
      exit 1
    end
    @driver = Selenium::WebDriver.for(:remote, :url => "http://#{ENV['SUT']}:4444/wd/hub")
    @base_url = "http://#{ENV['SUT']}:9000"
    @accept_next_alert = true
    @driver.manage.timeouts.implicit_wait = 30
    @verification_errors = []
  end

  def teardown
    @driver.quit
    assert_equal [], @verification_errors
  end

  def screenshot(filename='/tmp/screenshot.png')
    screenshot = @selenium.capture_entire_page_screenshot_to_string("")
    File.open(filename, 'wb') do|f|
      f.write(Base64.decode64(screenshot))
    end
  end

  def login
    @driver.get(@base_url + "/")
    @driver.find_element(:id, "username").clear
    @driver.find_element(:id, "username").send_keys "admin"
    @driver.find_element(:id, "password").clear
    @driver.find_element(:id, "password").send_keys "admin"
    @driver.find_element(:id, "signin").click
  end

  def logout
    @driver.get(@base_url + "/logout")
  end
  
  def element_present?(how, what)
    @driver.find_element(how, what)
    true
  rescue Selenium::WebDriver::Error::NoSuchElementError
    false
  end
  
  def alert_present?()
    @driver.switch_to.alert
    true
  rescue Selenium::WebDriver::Error::NoAlertPresentError
    false
  end
  
  def verify(&blk)
    yield
  rescue Test::Unit::AssertionFailedError => ex
    @verification_errors << ex
  end
  
  def close_alert_and_get_its_text(how, what)
    alert = @driver.switch_to().alert()
    alert_text = alert.text
    if (@accept_next_alert) then
      alert.accept()
    else
      alert.dismiss()
    end
    alert_text
  ensure
    @accept_next_alert = true
  end
end

