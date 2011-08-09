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
	
	gem 'authlogic'
	gem 'rails3-generators' # for the authlogic generators
	
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

    $ cucumber
    Using the default profile...
	uninitialized constant User (NameError)

## 3. Adding the basic user model

Crack out the rails generator to make us a User model to satisfy cucumber:

    $ rails generate model User login:string crypted_password:string \
    password_salt:string persistence_token:string

And rake the db:migration:

    $ rake db:migrate db:test:prepare

Only one change needed to the User model, to tell Authlogic to handle it:

    class User < ActiveRecord::Base
	  acts_as_authentic
	end
	
What does cucumber tell us to do now?

    $ cucumber
	Using the default profile...
	Feature: Testing Authlogic

	  Scenario: Logging in                             # features/authlogic.feature:2
	    Given the following user exists:               # factory_girl-2.0.3/lib/factory_girl/step_definitions.rb:98
	      | login | password | password_confirmation |
	      | Tony  | pass     | pass                  |
	    When I log in as "Tony" with password "pass"   # features/authlogic.feature:6
	      Undefined step: "I log in as "Tony" with password "pass"" (Cucumber::Undefined)
	      features/authlogic.feature:6:in `When I log in as "Tony" with password "pass"'
	
Cool, the first step passes. But how do we log in?

## 4. User Session model

We'll be generating a new model, UserSession, which will control sessions of users, so let's add the first missing cucumber step definition to test this. Create this in `./features/step_definitions/authlogic_steps.rb`:

    When /^I log in as "([^"]*)" with password "([^"]*)"$/ do |login, password|
	  UserSession.create(:login => login, :password => password, :remember_me => true)
	end
	
Cucumber tells us we need a UserSession class. So let's create it!

Generate a new model for UserSession using the Authlogic generator:

    $ rails generate authlogic:session UserSession
	
Now cucumber tells us:

    You must activate the Authlogic::Session::Base.controller with a controller object before creating objects (Authlogic::Session::Activation::NotActivatedError)
	
OK, so we need a session controller.

## 5. Session controller

**TODO**