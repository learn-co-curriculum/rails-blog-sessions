#TUTORIAL

##“Signing up”

1. Create a new migration for our users table that makes the following columns: email and password_digest (both strings). Create a validation on email presence and uniqueness on the user model.
 - `rake db:migrate RAILS_ENV=test`
 - add email and password_digest to user table: 
 -- `rails g migration AddEmailAndPasswordDigestToUsers email password_digest --no-test-framework`
 - Create a validation on email presence and uniqueness on the user model: 
 -- `validates_uniqueness_of :name, :email`
 -- `validates_presence_of :name, :email`
 - `rake db:migrate RAILS_ENV=test again`

2. Add the 'bcrypt' gem to our Gemfile to use the Active Record has_secure_password method, which adds methods to set and authenticate against BCrypt passwords. We don't need to create validations for password presence, because it's included within this method.
 - uncomment `bcrypt` gem and `bundle`
 - add `has_secure_password` to the user model

3. Now we have password and password_confirmation attributes (which we can permit in params on the users controller). Note that these aren't columns on our database, but attributes handled by the bcrypt gem.
 - `params.require(:user).permit(:name, :password, :password_confirmation)`
 - You will also need to add `:email` to strong params

4. Let's fix our routes to have a route for signup that points to the "new" method on our users controller.
 - In routes.rb add: `get '/signup', to: 'users#new', as: ‘signup’`

5. On the create method in the users controller, point a successful sign up to a root_path (posts index page) that we'll make in our routes file.
 - set root route to: `root 'posts#index’`
 - set `session[:user_id] = @user.id`
 - in users#create `redirect_to root_path, notice: "Thank you for signing up, #{@user.name}!”`
 - add `<%= notice %>` to application.html.erb in order to display the notice we set in the controller

6. Update our form for creating a new user to include email, password, and password confirmation. The passwords should have a password_field input.
 - ```Ruby 
  <div class="field">
    <%= f.label :name %><br>
    <%= f.text_field :name %><br>
    <%= f.label :email %><br>
    <%= f.text_field :email %><br>
    <%= f.label :password %><br>
    <%= f.password_field :password %><br>
    <%= f.label :password_confirmation %><br>
    <%= f.password_field :password_confirmation %><br>
  </div>
  ```

7. Let's also build out a _header partial that we render in application.html.erb that will have a Sign Up link, and other helpful navigation links.
 - In `app/views/layouts/_header.html.erb`:
 - ```Ruby
 <ul>
  <li><%= link_to("Home", root_path) %></li>
  <li><%= link_to("Sign Up", signup_path) %></li>
  <li><%= link_to("Log In", login_path) %></li>
  <li><%= link_to("Sign Out", signout_path) %></li>
</ul>
```
 - In application.html.erb: `<%= render "header" %>`


##Logging in with Sessions

1. Generate a Sessions controller. We'll make the views later. Our sessions controller will handle two actions, creating a new session and destroying it. A new session is generated when a user logs in or signs up (which is handled on the users controller by the create method.
 - command line:  `rails g controller Sessions create destroy --no-test-framework`

2. In sessions#create, you will need to find a user by their email and authenticate it (calling.authenticate) on the password from params. Then assign the session[:user_id] to the user.id.
- ```Ruby
  def create
    user = User.find_by({email: params[:email]})
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path, notice: “Hello, #{user.name}!"
    else
      flash.now.alert = "Invalid email and password confirmation"
      render 'new'
    end
  end
```

3. Build out the appropriate routes for these actions, and include a resource for sessions.
 - `resources :sessions`

4. Add to your _header nav links for logging out and logging in, and render a form as a form_tag for logging in under sessions (make it a partial and render it in a new view); it should post to the sessions_path.
 - Create nice login/logout routes: 
 -- `get '/login', to: 'sessions#new', as: 'login'`
 -- `get '/logout', to: 'sessions#destroy', as: ‘logout’`
 - Add to _header
 -- `<li><%= link_to("Login", login_path) %></li>`
 -- `<li><%= link_to("Logout", logout_path) %></li>`
 - form_tag form for login
 --
```Ruby
<div class="field">
  <%= form_tag sessions_path do %>
    <%= label_tag :email %><br>
    <%= text_field_tag :email %><br>
    <%= label_tag :password %><br>
    <%= password_field_tag :password %><br>
    <%= label_tag :password_confirmation %><br>
    <%= password_field_tag :password_confirmation %>
  <div class="actions">
      <%= submit_tag “Log In" %>
    <% end %>
  </div>
</div>
```

 - render _loginform in sessions#new

5. Now we can associate submitting a post and comment with a user via the session["user_id"]. Include a hidden_field tag on both forms to handle that association. Now refactor the show pages to display the user for comments and posts.
 -
 ```Ruby
  <div class="field">
    <%= f.hidden_field :user_id, :value => session[:user_id] %>
  </div>

  <h3>Title:</h3>
  <%= @post.name %>

  <h3>Content:</h3>
  <%= @post.content %>

  <h3>Author:</h3>
  <%= @post.user.name %>
```

## Signing up with Sessions

1. Make sure that when a new user signs up, their session is stored as well. You can handle this by setting the session id with the user id when creating a new user.
 - set `session[:user_id] = @user.id`

## Authenticating with Sessions

1. Now that we have sessions, we can create conditionals on various actions in our app. Let's make it that a user must be logged in to post a post or submit a comment.
In the application controller, make a private `helper_method` called `current_user` that will find a user by their session id and assign to an instance variable `@current_user`. 
  - In Application controller:
  ```Ruby
  def current_user
    @current_user ||= session[:user_id] && User.find_by_id(session[:user_id])
  end
  ```

  `helper_method :current_user`

2. Make another helper method `user_signed_in?` that checks for a session user_id and returns true or false
  - In Application controller:
  ```Ruby
    def user_signed_in?
      session[:user_id] ? true:false
    end
  ```

3. Also add `user_signed_in?` to the helper_method in application controller
  - `helper_method :current_user, :user_signed_in?`

4. Let's also make a method `authorize` that renders our login page if a `!user_signed_in?`. We're going to call this method as a [before_action](http://guides.rubyonrails.org/action_controller_overview.html#filters) on our comments and posts controllers that will run this check before the edit, update, create, new, and destroy methods.
 - In Application controller:
  ```Ruby
  def authorize
    !user_signed_in?
  end
  ```
 - `before_action :authorize` in comments controller
 - `before_action :authorize, except: [:show]` in posts controller

5. This will help us in our header to render info about the logged in user and create some view logic to only render a logout link and new post link if the user is logged in. Have the current user's name displayed too to let them know they're logged in.
 - `<% if user_signed_in? %>`

6. Refactor our forms that handle new comments to check if the user is signed in.
 - `<% if user_signed_in? %>`


