#Rails Blog Sessions Topic Review
---
##Learning Objectives
1. What is a session?
2. Why it’s useful?
3. How to create one?

##Setup
Before the lab-review begins:

1. `rake db:migrate RAILS_ENV=test` and `rake db:migrate RAILS_ENV=development`
2. `rake db:seed`
3. `rails s`

##Providing Context

* Visit localhost:3000/posts/new and create a new post

Point out that there are currently no users. This app has no concept of a user. All posts are lumped into the same pile. There's no way for me to see just the posts that I created. There is no way to see who left a comment on my post. Right now, anyone can edit or delete my post.

Step by step, we'll fix this by:

1. Creating the conditions to sign up a user (See Step 1 in the Tutorial) -- I would do this step before the review to focus entirely on sessions during the review.
2. Implementing the concept of sessions to keep track which user is logged in (See Step 2 in the Tutorial)
3. Authenticating that the user is logged in before allowing them to write a post or comment (See Step 3 in the Tutorial)

##What is a Session?
-cookie, way to keep track of a user. browser is stateless...

##Why is it useful?
-keep track of a logged in user
-it's how we will determine whether a user can perform certain actions such as posting, commenting, deleting a post

##Creating a Session

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

