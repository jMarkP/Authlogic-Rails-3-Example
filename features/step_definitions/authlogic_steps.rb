require "authlogic/test_case" 
Before do 
  activate_authlogic 
end

When /^I log in as "([^"]*)" with password "([^"]*)"$/ do |login, password|
  UserSession.create(:login => login, :password => password, :remember_me => true)
end

Then /^the current user's login should be "([^"]*)"$/ do |expected_login|
  current_session = UserSession.find
  current_session.user.login.should == expected_login
end
