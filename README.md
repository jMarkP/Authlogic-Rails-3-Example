# Authlogic Rails 3 Example

All the examples for Authlogic I found seemed to not be written with Rails 3 in mind. So here's my simple example of setting up a basic Rails 3 app with Authlogic.

Also uses some other trendy Ruby stuff including:

* [Cucumber](https://github.com/cucumber/cucumber)
* [FactoryGirl](https://github.com/thoughtbot/factory_girl)

## 0. Pre-requisites

You have a useable Rails environment. That is you can run

    $ gem install authlogic
    $ rails new my_app

and it does its stuff.

## 1. Setup basic Rails app

Run up rails to generate your new app (skip if you are adding to an existing app. Obviously).

    $ rails new authlogic_rails3

## 2. Add cucumber feature

Add the following to `./Gemfile`:

    group :test do
	  gem 'cucumber-rails', '1.0.1'
	  gem 'rspec-rails', '2.6.1'
	  gem 'database_cleaner', '0.6.7'
  	  gem 'factory_girl_rails', '~> 1.1'
	end
	
And run the following in the app's root directory:

    $ bundle install
    $ rails generate cucumber:install

Now create a new feature `authlogic.feature`:

    Feature: Testing Authlogic
		Scenario: Logging in
			Given the following user exists:
				| login    | password   | password_confirmation |
				| Tony     | pass       | pass                  |
			When I log in as "Tony" with password "pass"
			Then the current user's login should be "Tony"
			
Running

    $ cucumber

of course fails because we haven't done anything (but we're good behaviour-driven developers and run our specs after every step).

### Factory Girl step definitions

Add the following as `./features/support/factory_girl.rb`:

    require 'factory_girl/step_definitions'

And this as `./features/support/factories.rb`:

	Factory.define :user do
	end
	
Cucumber still fails, but we're getting there.