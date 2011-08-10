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

You can add any other fields here you need. See the Authlogic documentation for other properties it will automatically recognise and support.

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
	
OK, so we need to activate Authlogic somehow. In the real app this will be done in a controller, but for now we can just tell cucumber to activate Authlogic before it runs the tests. So add the following at the top of `authlogic_steps.rb`:

    require "authlogic/test_case" 
	
	Before do 
	  activate_authlogic 
	end

Now the *When* step passes! Great.

### Verifying that we logged in

The final step to make this feature pass is to check that the current session contains our mate Tony. Add this to `authlogic_steps.rb`:

    Then /^the current user's login should be "([^"]*)"$/ do |expected_login|
	  current_session = UserSession.find
	  current_session.user.login.should == expected_login
	end
	
We grab the current session (`UserSession.find`) and ask it for its `user`, then we check that the current user's `login` field is as expected.

Now the first cucumber feature passes! Job done.

This means the model layer is now working as expected. But we'd like to be able to actually *use* this new authentication system in the Rails app. So we should test the controller and view layers as well...

## 5. User interface integration testing

### Separating scenario types

First of all I'm going to mark our existing scenario with a `@model` tag so that I can tell cucumber to do the manual Authlogic activation for scenarios tagged `@model`:

**authlogic.feature**
    
    @model
	Scenario: Logging in
		Given the following user exists:
			| login    | password   | password_confirmation |
			| Tony     | pass       | pass                  |
		When I log in as "Tony" with password "pass"
		Then the current user's login should be "Tony"
		
**authlogic_steps.rb**

	require "authlogic/test_case" 
	Before('@model') do 
	  activate_authlogic 
	end
	...
	
### A new scenario
	
Now let's specify a new scenario for creating a new user through the user interface:

    Scenario: Signing up
		Given there are no users
		And I am on the new user page
		And I fill in the following:
			| Login		            | Sally      |
			| Password              | newpass    |
			| Password confirmation | newpass    |
		When I press "Create"
		Then a new User account for "Sally" should be created
		And the current user's login should be "Sally"
	
Cucumber tells us it doesn't know how to ensure there are no users. Let's tell it:

    Given /^there are no users$/ do
	  User.all.count.should == 0
	end
	
### Routes

Now we're told:

    Can't find mapping from "the new user page" to a path.
	      Now, go and add a mapping in /Users/development/dev/ruby/scratch/authlogoic_rails3/features/support/paths.rb (RuntimeError)
	
We need a route to a new user page. Let's create a user controller:

    $ rails generate controller users	
	
And tell Rails about it in `./config/routes.rb`:

    AuthlogoicRails3::Application.routes.draw do
	  resources :users
	end
	
Now show yourself that the new user route is available:

    $ rake routes
	    users GET    /users(.:format)          {:action=>"index", :controller=>"users"}
	          POST   /users(.:format)          {:action=>"create", :controller=>"users"}
	 new_user GET    /users/new(.:format)      {:action=>"new", :controller=>"users"}
	edit_user GET    /users/:id/edit(.:format) {:action=>"edit", :controller=>"users"}
	     user GET    /users/:id(.:format)      {:action=>"show", :controller=>"users"}
	          PUT    /users/:id(.:format)      {:action=>"update", :controller=>"users"}
	          DELETE /users/:id(.:format)      {:action=>"destroy", :controller=>"users"}
	
Great, there it is.

Cucumber now has a different complaint:

    The action 'new' could not be found for UsersController (AbstractController::ActionNotFound)
	
Easy to fix. Add a `new` action to `UsersController`:

    class UsersController < ApplicationController

	  def new
	    @user = User.new
	  end

	end

...and a corresponding view (`./app/views/users/new.html.erb`) with a simple form:
	
	<%= form_for @user do |f| %>
	  <%= f.label :login %>
	  <%= f.text_field :login %>
	  <%= f.label :password %>
	  <%= f.text_field :password %>
	  <%= f.label :password_confirmation %>
	  <%= f.text_field :password_confirmation %>
	  <%= submit_tag "Create" %>
	<% end %>
	
Cucumber now says it can't find the create action.  Let's add it:

    def create
	  @user = User.new(params[:user])
	  if @user.save
        flash[:notice] = "Account registered!"
	    redirect_to account_url
	  else
	    render :action => :new
	  end
	end
	
### Creating the user
	
Now we need to ensure that the new user does get created.

---
	
Let's ask Rails to create us a new User Sessions controller:

    $ rails generate controller user_sessions

And fill in the recommended controller code from the [Authlogic example project](https://github.com/binarylogic/authlogic_example/blob/master/app/controllers/user_sessions_controller.rb):

    class UserSessionsController < ApplicationController
	  before_filter :require_no_user, :only => [:new, :create]
	  before_filter :require_user, :only => :destroy

	  def new
	    @user_session = UserSession.new
	  end

	  def create
	    @user_session = UserSession.new(params[:user_session])
	    if @user_session.save
	      flash[:notice] = "Login successful!"
	      redirect_back_or_default account_url
	    else
	      render :action => :new
	    end
	  end

	  def destroy
	    current_user_session.destroy
	    flash[:notice] = "Logout successful!"
	    redirect_back_or_default new_user_session_url
	  end
	end
	
We also need to add some code to the base `ApplicationController`, again, as per the Authlogic example. **Except:** Rails 3 no longer supports setting `filter_parameter_logging` in the Application controller, you must specify it in the `config/application.rb` file instead:

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation]

So now the Application controller looks like this:

    class ApplicationController < ActionController::Base
	  protect_from_forgery

	  helper :all
	  helper_method :current_user_session, :current_user

	  private
	    def current_user_session
	      return @current_user_session if defined?(@current_user_session)
	      @current_user_session = UserSession.find
	    end

	    def current_user
	      return @current_user if defined?(@current_user)
	      @current_user = current_user_session && current_user_session.record
	    end

	    def require_user
	      unless current_user
	        store_location
	        flash[:notice] = "You must be logged in to access this page"
	        redirect_to new_user_session_url
	        return false
	      end
	    end

	    def require_no_user
	      if current_user
	        store_location
	        flash[:notice] = "You must be logged out to access this page"
	        redirect_to account_url
	        return false
	      end
	    end

	    def store_location
	      session[:return_to] = request.request_uri
	    end

	    def redirect_back_or_default(default)
	      redirect_to(session[:return_to] || default)
	      session[:return_to] = nil
	    end
	end
	