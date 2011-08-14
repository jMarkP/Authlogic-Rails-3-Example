require "authlogic/test_case" 

Before('@model') do 
  activate_authlogic 
end

When /^I log in as "([^"]*)" with password "([^"]*)"$/ do |login, password|
  UserSession.create(:login => login, :password => password, :remember_me => true)
end

Then /^the current user's login should be "([^"]*)"$/ do |expected_login|
  current_session = UserSession.find
  current_session.user.login.should == expected_login
end

Given /^there are no users$/ do
  User.all.count.should == 0
end

Then /^a new User account for "([^"]*)" should be created$/ do |user_login|
  the_user = User.find_by_login(user_login)
  the_user.should_not be_nil
  the_user.login.should eq(user_login)
end

