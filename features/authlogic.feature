Feature: Testing Authlogic
	Scenario: Logging in
		Given the following user exists:
			| login    | password   | password_confirmation |
			| Tony     | pass       | pass                  |
		When I log in as "Tony" with password "pass"
		Then the current user's login should be "Tony"