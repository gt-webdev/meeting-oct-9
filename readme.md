# wtf2eat app!

We're turning out ever popular and super interesting Sinatra dinner app into a Rails app to familiarize you with the Rails-y way of doing things. Something we're going to touch on for this meeting:

1. Dinner model (and querying the database)
2. Routing
3. Dinner controller + action
4. Views

Alright, so let's get started.

## Prerequisites 

People on Linux make sure you have the following packages installed:

    sqlite3
    libsqlite3
    libreadline-dev

Everyone then runs ``gem install rails``

## Creating the Rails app!

After running ``gem install rails`` you should be able to create a new project using ``rails new wtf2eat``. You'll get a whoooole bunch of output that'll look like this

```
gtwebdev|⇒ rails new wtf2eat
      create  
      create  README.rdoc
      create  Rakefile
      create  config.ru
      create  .gitignore
      create  Gemfile
      create  app
      create  app/assets/images/rails.png
      create  app/assets/javascripts/application.js
      create  app/assets/stylesheets/application.css
      create  app/controllers/application_controller.rb
      create  app/helpers/application_helper.rb
      create  app/mailers
      create  app/models
      create  app/views/layouts/application.html.erb
      create  app/mailers/.gitkeep
      create  app/models/.gitkeep
      create  config
      create  config/routes.rb
      create  config/application.rb
      create  config/environment.rb
      create  config/environments
      create  config/environments/development.rb
      create  config/environments/production.rb
      create  config/environments/test.rb
      create  config/initializers
      create  config/initializers/backtrace_silencers.rb
      create  config/initializers/inflections.rb
      create  config/initializers/mime_types.rb
      create  config/initializers/secret_token.rb
      create  config/initializers/session_store.rb
      create  config/initializers/wrap_parameters.rb
      create  config/locales
...
```
And it keeps going, but don't freak out! We'll walk through this step-by-step implementing the Sinatra app in Rails.

``cd`` into the Rails app and let's start playing around.

## The model

One thing we didn't really cover in the Sinatra app is creating models and hooking up to the database. Before we saved everything in memory which means that whenever the app stopped we'd lose all of our data but now anymore. Everything we do in Rails will be backed against a database and persisted forever!

Go ahead and generate a new dinner model

```
rails generate model dinner name:string
```

(Rails comes with these things called generators that we will not be using very often. I like to use them for models because they don't create a whole lot of stuff and it's easy to work with.)

What we did here was create a model called ``Dinner`` with one attribute called name. If we check out the migration (``db/migration/*_create_dinners.rb``) file it generated we'll see that Rails handle creating the table and columns for us

```
class CreateDinners < ActiveRecord::Migration
  def change
    create_table :dinners do |t|
      t.string :name

      t.timestamps
    end
  end
end
```

Yay! We don't have to write any SQL by hand. This is already awesome. Run ``rake db:migrate`` and Rails will create the table for you.

Now, open up the Rails console and let's explore a bit.

```
wtf2eat|⇒ rails console
Loading development environment (Rails 3.2.8)
1.9.3p194 :001 > 
```

> ### The Rails Console
>
> Rails provides you with an interactive console that actually loads the entire app for you. That means you can do things like query the database with your models from inside the console! It's awesome for testing and for sanity checks to make sure stuff is actually working as intended. 

Last time, we briefly mentioned ``ActiveRecord`` and the idea of ORM (Object Relational Mapping) to suggest that we can use Ruby code to query the database instead of writing SQL. It's pretty easy to do!

Let's get all the dinners!

```
1.9.3p194 :001 > Dinner.all
  Dinner Load (0.6ms)  SELECT "dinners".* FROM "dinners" 
 => [] 
1.9.3p194 :002 > 
```

Two things to note here: ``.all`` is an ActiveRecord method to retrieve all of the values from the ``Dinner`` model. Secondly, you can see the actual SQL it's running.

Let's create something using ``Dinner.create``

```
1.9.3p194 :002 > d1 = Dinner.create(name: 'Foie Gras')
   (0.1ms)  begin transaction
  SQL (7.4ms)  INSERT INTO "dinners" ("created_at", "name", "updated_at") VALUES (?, ?, ?)  [["created_at", Tue, 09 Oct 2012 00:08:49 UTC +00:00], ["name", "Foie Gras"], ["updated_at", Tue, 09 Oct 2012 00:08:49 UTC +00:00]]
   (1.2ms)  commit transaction
 => #<Dinner id: 1, name: "Foie Gras", created_at: "2012-10-09 00:08:49", updated_at: "2012-10-09 00:08:49"> 
1.9.3p194 :003 > 
```

You can see the SQL that Rails is running to create the record. Note that you can pass is named attributes into the method! That makes it really easy to specify what values you want to create.

Create another dinner: ``d2 = Dinner.create(name: 'Deep Fried Butter On A Stick')``

If we run ``Dinner.all`` again we'll get both dinners from the database

```
1.9.3p194 :007 > Dinner.all
  Dinner Load (0.2ms)  SELECT "dinners".* FROM "dinners" 
 => [#<Dinner id: 1, name: "Foie Gras", created_at: "2012-10-09 00:08:49", updated_at: "2012-10-09 00:08:49">, #<Dinner id: 2, name: "Deep Fried Butter On A Stick", created_at: "2012-10-09 00:19:21", updated_at: "2012-10-09 00:19:21">] 
1.9.3p194 :008 > 
```

Now, what if we want to find a specific dinner? There are two methods that'll help us here: ``Dinner.find(id)`` and ``Dinner.find_by_name(name)``. The interesting one here is ``find_by_name`` which is dynamically created by Rails based on the fact that ``Dinner`` has an attribute called name. These method will be created for every attribute that you have.

Cool, so we have the model, let's get to routes, controller, and views.

## Routes, Controllers, and Views

### Routes

In Sinatra, we defined the route by actually specifying it in the method

```
get '/' do
  # …
end
```

Rails provides you with a routes file to conveniently place all of your routes in. This will be hugely beneficial as we will soon discover.

Lets go ahead and add a routes for dinner. Open up ``config/routes.rb`` and add ``resources :dinner`` under the first line

```
Wtf2eat::Application.routes.draw do
  resources :dinner
  # …
end
```

In terminal, run ``rake routes``

```
wtf2eat|⇒ rake routes
dinner_index GET    /dinner(.:format)          dinner#index
             POST   /dinner(.:format)          dinner#create
  new_dinner GET    /dinner/new(.:format)      dinner#new
 edit_dinner GET    /dinner/:id/edit(.:format) dinner#edit
      dinner GET    /dinner/:id(.:format)      dinner#show
             PUT    /dinner/:id(.:format)      dinner#update
             DELETE /dinner/:id(.:format)      dinner#destroy
```

You see here that aaaall of a sudden you have a number of routes created for you just by adding one line. Magical, right?!

Now we need to create the controller so stuff can happen.

### Controller

Create a file inside of ``app/controllers`` called ``dinners_controller.rb``

