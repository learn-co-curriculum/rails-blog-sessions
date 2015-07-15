##Guide To Solving Rails Blog Sessions

###Objective:
- Have User Sign Up
- Sign In
- Sign Out

###Home Page Overview
When we visit `localhost:3000` we want to see links to `Sign Up`, `Sign In` and `Log Out`, just like you would on any typical website. In order to make this happen we are going to need a view with the links, as well as the links themselves. When you click on a link, it will need to know which route it is sending the request to, as well as a controller to route the request. On a lower level we will need a `User` model, which is partially built for us, to handle the data and create a session. With that said, let's take a look at the README.md.

Right now we have a `Users` table with a `name` attribute. We need to add an `email` and `password_digest` field so a user can log in. Let's do that now.

What is a password digest? It is the encrypted version of your password.  First let's create our migrations.

###Users Table Migrations

`rails g migration AddEmailAndPasswordDigestToUser email:string password_digest:string`

Now let's run `rake db:migrate RAILS_ENV=test` to migrate our test database.

###Start Server
Since we are working with Rails, let's go ahead and start our server with `rails s` and visit `localhost:3000/users` just to make sure everything is running.

###Validations

Let's go ahead and create our validations in our `User` model.

```
class User < ActiveRecord::Base
  has_many :posts
  has_many :comments

  validates_uniqueness_of :name
  validates_presence_of :name
end

```

###Bcrypt
Now we are going to add the `bcrypt` gem to our gemfile. `Bcrypt` is going to give us access to a method called `has_secure_password` which adds methods to set and authenticate against BCrypt passwords. We don't need to create validations for password presence, because it's included within this method.

`bundle install` to update your gemfile

Now we have password and password_confirmation attributes (which we can permit in params on the users controller). Note that these aren't columns on our database, but attributes handled by the bcrypt gem.

Let's go ahead and give the `User` the `has_secure_password_method`.

```ruby
class User < ActiveRecord::Base
  has_many :posts
  has_many :comments

  validates_uniqueness_of :name
  validates_presence_of :name

  validates_uniqueness_of :email
  validates_presence_of :email

  has_secure_password
end
```
Let's run `rspec`
`No route matches [GET] "/"`

Looks like we need to set up our index route, let's do that.

####`config/routes.rb`
`root 'posts#index'`

Run `rspec` again and you will get your next error.

`Unable to find link "Sign Up"`

Capybara is tring to find a Sign Up link on our homepage. If we look at our home page via `localhost:3000`, we can see that we are missing a link.  Let's first take a look at our spec and see exactly what the test is testing for, instead of just guesing.

```ruby
def login_valid
  visit '/'
  click_link('Log In')
  expect(current_path).to eq('/login')
  fill_in(:email, :with => @crookshanks.email)
  fill_in(:password, :with => @crookshanks.password)
  click_button('Log In')
  expect(current_path).to eq('/')
  expect(page).to have_content("Hello, #{@crookshanks.name}!")
end
```
We need to vist `/` and click on a link that says `Log In`, it expects that path to be equal to `/login`. So let's start there. In order to make that happen we will need to define a `/login` route and create a link on our `/` page that points to it.

###`posts/index`
`<%= link_to 'Sign Up', signup_path %>
`

###`config/routes.rb`
`get 'signup' => 'users#new', :as => 'signup'`

Run `rspec` and you should see `Unable to find field "Email"`
This is good, we now have a link to click and route to send it to. Acording to our test, we need to have an email and password field to fill in, so let's create those. Add the following fields to your forms.

###`users/_form.rb`

```ruby
<div class="field">
  <%= f.label :email %><br>
  <%= f.text_field :email %><br>
</div>
 <div class="field">
  <%= f.label :password %><br>
  <%= f.text_field :password %><br>
</div>
<div class="field">
  <%= f.label :password_confirmation %><br>
  <%= f.text_field :password_confirmation %><br>
</div>
  <%= f.submit 'Sign Up' %>
```
Now we have our form ready to go, let's go ahead and submit it. What happened? There are two things we need to make sure we do. The first is white list our data in the users controller.

###`users_controller`
```ruby
def user_params
  params.require(:user).permit(:name, :email, :password, :password_confirmation)
end
```
The second is change where our `create` action is sending us after it logs us in.

###`users_controller`

```ruby
def create
  @user = User.new(user_params)
  if @user.save
    redirect_to root_path, :notice => "Thank you for signing up!"
  else
    render :new
  end
end
```
Great, we can now sign our user in. The last piece is letting them remain logged in. To do that, after a user is successfully saved we have to point their `id` to their sessions id, this is what it mans to be "logged in." We will do that in the user controller.

###`users_controller`
```ruby
def create
  @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, :notice => "Thank you for signing up!"
    else
      render :new
  end
end
```

