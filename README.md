# Authlogic Rails 3 Example

All the examples for Authlogic I found seemed to not be written with Rails 3 in mind. So here's my simple example of setting up a basic Rails 3 app with Authlogic.

Also uses some other trendy Ruby stuff including:

* [Cucumber](https://github.com/cucumber/cucumber)
* [FactoryGirl](https://github.com/thoughtbot/factory_girl)

---

## 0. Pre-requisites

You have a useable Rails environment. That is you can run

    $ gem install authlogic
    $ rails new my_app

and it does its stuff.

## 1. Setup basic Rails app

Run up rails to generate your new app (skip if you are adding to an existing app. Obviously).

    $ rails new authlogic_rails3
	      create  
	      create  README
	      create  Rakefile
	      create  config.ru
	      create  .gitignore
	      create  Gemfile
	      create  app
	      create  app/assets/images/rails.png
    ...
	      create  vendor/assets/stylesheets
	      create  vendor/assets/stylesheets/.gitkeep
	      create  vendor/plugins
	      create  vendor/plugins/.gitkeep
	         run  bundle install

