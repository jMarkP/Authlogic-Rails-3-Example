When /^I log in as "([^"]*)" with password "([^"]*)"$/ do |login, password|
  UserSession.create(:login => login, :password => password, :remember_me => true)
end