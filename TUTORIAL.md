##Guide to Solving and Reviewing Rails Blog Sessions

###Objectives
By the end of this lab you should understand what a session is and how to implement them. To achieve this we will:

1. Build out a signup and login system using sessions
2. Prevent a user from performing certain actions (writing a blog post or comment) without logging in

###Basic Setup
1. Setup the test and development databases by running `rake db:migrate RAILS_ENV=test` and `rake db:migrate RAILS_ENV=development` in the terminal
2. Seed the database: `rake db:seed` in the terminal
2. Start your server: `rails s` in the terminal


###Conceptualizing the Problem
Play with the existing code to understand how the app works. Look at the `routes.rb`. Look at the Controllers. Since this app is about creating blog posts, let's check out the page to create a new post. Visit `localhost:3000/posts/new`. 

Create a post. This works, but what are the limitations with this post?

This app has no concept of a user. All posts are lumped into the same pile. There's no way for me to see just the posts that I created. There is no way to see who left a comment on our post. Because there is no concept of a user, anyone can edit or delete anyone else's post. 

Step by step, we'll fix this by:

1. creating the conditions to sign up a user
2. implementing the concept of sessions to keep track which user is logged in
3. authenticating that the user is logged in before allowing them to write a post or comment



### Step 1. Signing up

1. Create a new migration for our users table that makes the following columns: email and password_digest (both strings). Create a validation on email presence and uniqueness on the user model.
 - add email and password_digest to user table: `rails g migration AddEmailAndPasswordDigestToUsers email password_digest --no-test-framework`
 - Create a validation on email presence and uniqueness on the user model: `validates_uniqueness_of :name, :email` and `validates_presence_of :name, :email`
 - `rake db:migrate RAILS_ENV=test` again

2. Add the 'bcrypt' gem to our Gemfile to use the Active Record has_secure_password method, which adds methods to set and authenticate against BCrypt passwords. We don't need to create validations for password presence, because it's included within this method.
 - uncomment `bcrypt` gem and `bundle`
 - add `has_secure_password` to the User model

3. Now we have password and password_confirmation attributes (which we can permit in params on the users controller). Note that these aren't columns on our database, but attributes handled by the bcrypt gem.
 - In the User controller:  `params.require(:user).permit(:name, :password, :password_confirmation)`
 - You will also need to add `:email` to strong params

4. Let's fix our routes to have a route for signup that points to the "new" method on our users controller.
 - In `routes.rb` add: `get '/signup', to: 'users#new', as: ‘signup’`

5. On the create method in the users controller, point a successful sign up to a root_path (posts index page) that we'll make in our routes file.
 - Set root route to: `root 'posts#index’`
 - In Users#Create: `redirect_to root_path, notice: "Thank you for signing up, #{@user.name}!”`
 - Add `<%= notice %>` to `application.html.erb` in order to display the notice we set in the controller

6. Update our form for creating a new user to include email, password, and password confirmation. The passwords should have a password_field input.

	```ruby
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

7. Let's also build out a _header partial that we render in `application.html.erb` that will have a Sign Up link, and other helpful navigation links.
 - In `app/views/layouts/_header.html.erb`:

		```ruby
		 <ul>
		  <li><%= link_to("Home", root_path) %></li>
		  <li><%= link_to("Sign Up", signup_path) %></li>
		  <li><%= link_to("Log In", login_path) %></li>
		  <li><%= link_to("Sign Out", signout_path) %></li>
		</ul>
		```
 - In application.html.erb: `<%= render "header" %>`


###Step 2. Logging in with Sessions

1. Generate a Sessions controller. We'll make the views later. Our sessions controller will handle two actions, creating a new session and destroying it. A new session is generated when a user logs in or signs up (which is handled on the users controller by the create method.
 - command line:  `rails g controller Sessions create destroy --no-test-framework`

2. In sessions#create, you will need to find a user by their email and authenticate it (calling.authenticate) on the password from params. Then assign the session[:user_id] to the user.id.

	```ruby
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

4. Add to your `_header` nav links for logging out and logging in, and render a form as a form_tag for logging in under sessions (make it a partial and render it in a new view); it should post to the sessions_path.
 - Create nice login/logout routes: `get '/login', to: 'sessions#new', as: 'login'` and `get '/logout', to: 'sessions#destroy', as: ‘logout’`
 - Add to `_header`:
 
		```
		 <li><%= link_to("Login", login_path) %></li>
		 <li><%= link_to("Logout", logout_path) %></li>
		``` 
 - form_tag form for login

		```ruby
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

 - render _login form in `sessions#new` view: `<%= render 'form' %>`

5. Now we can associate submitting a post and comment with a user via the `session["user_id"]`. Include a `hidden_field` tag on both forms to handle that association. Now refactor the show pages to display the user for comments and posts.
 
 ```ruby
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

### Signing up with Sessions

1. Now that we have sessions, make sure that when a new user signs up their session is stored as well. You can handle this by setting the session id with the user id when creating a new user.
 - In `user#create` set `session[:user_id] = @user.id`

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

### Step 3. Authenticating with Sessions

1. Now that we have sessions, we can create conditionals on various actions in our app. Let's make it that a user must be logged in to post a post or submit a comment.
In the application controller, make a private `helper_method` called `current_user` that will find a user by their session id and assign to an instance variable `@current_user`. 
  - In Application controller:

	  ```ruby
	  def current_user
	  	  @current_user ||= session[:user_id] && User.find_by_id(session[:user_id])
	  end
	  ```

  		`helper_method :current_user`

2. Make another helper method `user_signed_in?` that checks for a session user_id and returns true or false
  - In Application controller:
  
	  ```ruby
	    def user_signed_in?
	      session[:user_id] ? true:false
	    end
	  ```

3. Also add `user_signed_in?` to the helper_method in application controller
  - `helper_method :current_user, :user_signed_in?`

4. Let's also make a method `authorize` that renders our login page if a `!user_signed_in?`. We're going to call this method as a [before_action](http://guides.rubyonrails.org/action_controller_overview.html#filters) on our comments and posts controllers that will run this check before the edit, update, create, new, and destroy methods.
 - In Application controller:
 
	  ```ruby
	  def authorize
	    !user_signed_in?
	  end
  ```
 - `before_action :authorize` in Comments controller
 - `before_action :authorize, except: [:show]` in Posts controller

5. This will help us in our header to render info about the logged in user and create some view logic to only render a logout link and new post link if the user is logged in. Have the current user's name displayed too to let them know they're logged in.
 - Add `<% if current_user %>` to `_header.html.erb` and `<li><a href="/users/<%=current_user.id%>"><%= "Hello, #{current_user.name}!" %></a></li>`

 ```ruby
 	<nav>
	  <ul>
	      <li><%= link_to 'Posts', posts_path %></li>
	      <% if current_user %>
	        <li><a href="/users/<%=current_user.id%>"><%= "Hello, #{current_user.name}!" %></a></li>
	        <li> <%= link_to 'New Post', new_post_path %> </li>
	        <li><%= link_to "Log Out", logout_path, method: :delete %></li>
	      <% else %>
	        <li><%= link_to "Sign Up", signup_path %></li>
	        <li><%= link_to "Log In", login_path %></li>
	      <% end %> 
	  </ul>
	</nav>
 ```

6. Refactor our forms that handle new comments to check if the user is signed in.
 - Wrap the "Comments" section with a `<% if user_signed_in? %>` conditional

 ```ruby
 	<% if user_signed_in? %>
	  <h3>Comments:</h3>
	    <% @post.comments.each do |comment| %>
	      <p><%= comment.content %> </p>
	      <p><%= binding.pry %> </p>
	      <p><%= comment.user.name %> </p>
	    <% end %>
	
	    <h4>Post a new comment:</h4>
	    <%= form_for [@post, Comment.new] do |f| %>
	      <div class="field">
	        <%= f.label :content %><br>
	        <%= f.text_area :content %><br>
	        <%= f.hidden_field :post_id, :value => @post.id %>
	      </div>
	
	      <div class="actions">
	        <%= f.submit %>
	      </div>
	    <% end %>
	<% else %>
	  "Log In to Comment!"
	<% end %>
 ```


