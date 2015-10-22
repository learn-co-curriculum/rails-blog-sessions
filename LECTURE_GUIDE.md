#Rails Blog Sessions Topic Review
---
##Learning Objectives
1. What is a session?
2. Why it’s useful?
3. How to create one

##Setup
Before the lab-review begins:

1. `rake db:migrate RAILS_ENV=test` and `rake db:migrate RAILS_ENV=development`
2. `rake db:seed`
3. `rails s`
4. All of Step 1 in `Tutorial.md`

##Providing Context

* Visit localhost:3000/posts/new and create a new post

Point out that there are currently no users. This app has no concept of a user. All posts are lumped into the same pile. There's no way for me to see just the posts that I created. There is no way to see who left a comment on my post. Right now, anyone can edit or delete my post.

Step by step, we'll fix this by:

1. Creating the conditions to sign up a user (See Step 1 in the Tutorial) -- I would do this step before the review to focus entirely on sessions during the review.
2. Implementing the concept of sessions to keep track which user is logged in (See Step 2 in the Tutorial)
3. Authenticating that the user is logged in before allowing them to write a post or comment (See Step 3 in the Tutorial)


##The problem: why we need a session?

Browsers are stateless, meaning they treat each request as an independent transaction that is unrelated to any previous request. The problem is that most apps need to be able to store some data about a user. Maybe it’s a user id, or a preferred language, or whether they always want to see the desktop version of your site on their iPad.


##The solution: what is a session?

A session is just a place to store data during one request that you can read during later requests.

-cookie


##How to create a session

1. Generate a Sessions controller: `rails g controller Sessions create destroy --no-test-framework`
2. Build the create action

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
3. Set up the routes
4. Form_tag form for login

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
5. a


##Why is it useful?

-keep track of a logged in user
-it's how we will determine whether a user can perform certain actions such as posting, commenting, deleting a post. Let's authenticate the user.

###Authentication
user must be logged in to post a post or submit a comment. 
Create application controller methods:
 
```ruby
  def current_user
    @current_user ||= session[:user_id] && User.find_by_id(session[:user_id])
  end

  def user_signed_in?
	session[:user_id] ? true:false
  end
  
  def authorize
	!user_signed_in?
  end
```

Then use those methods to make sure the user logs in before they reach certain pages (eg `new_post_path`) or see certain sections of the page (eg comment section)
