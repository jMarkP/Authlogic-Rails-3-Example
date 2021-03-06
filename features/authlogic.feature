Feature: Testing Authlogic

	@model
	Scenario: Logging in
		Given the following user exists:
			| login    | password   | password_confirmation |
			| Tony     | pass       | pass                  |
		When I log in as "Tony" with password "pass"
		Then the current user's login should be "Tony"	

	Scenario: Logging in through the user interface
		Given the following user exists:
			| login    | password   | password_confirmation |
			| Virginia | pass       | pass                  |
		And I am on the login page
		And I fill in the following:
			| Login     | Virginia   |
			| Password  | pass       |
		When I press "Login"
		Then I should be on the home page
		And the current user's login should be "Virginia"
			
	Scenario: Signing up
		Given there are no users
		And I am on the new user page
		And I fill in the following:
			| Login		            | Sally      |
			| Password              | newpass    |
			| Password confirmation | newpass    |
		When I press "Create"
		Then I should be on the home page
		And a new User account for "Sally" should be created
		And the current user's login should be "Sally"