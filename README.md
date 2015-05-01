# Nano-Twitter <img alt="Status?branch=master" src="https://codeship.com/projects/50007a90-ae63-0132-7ed9-2ecd9a04cc80/status?branch=master" /> <a href="https://codeclimate.com/github/arikalfus/Nano-Twitter"><img src="https://codeclimate.com/github/arikalfus/Nano-Twitter/badges/gpa.svg" /></a>

Project focusing on load testing for COSI 105B: Architecture at Scale at Brandeis University. See it <a href=http://nano-twitter.herokuapp.com">on Heroku</a>.

#####Gems used in project:
  - <a href="https://github.com/lyokato/sinatra-formkeeper">Formkeeper</a>
  - <a href="https://github.com/redis/redis-rb">Redis</a>
  - <a href="https://github.com/stympy/faker">Faker</a>

# Route descriptions

## Get Routes
###get '/'
  - Makes sure the login cookie is valid (if present)
  - Shows the current homepage, depending on whether or not the user is logged in or not.
  - Gets the 100 most recent tweets, from all users if not logged in, or from the users followees if they are logged in.

###get '/logout'
  - Redirects to ```/nanotwitter/v1.0/logout``` if user is logged in.
  - Loads the root page with 100 most recent tweets of all users.

###get '/nanotwitter/v1.0/logout'
  - Deletes the session cookie, then redirects to ```/logout```

###get '/nanotwitter/v1.0/users/:username'
  - Gets a user and their tweets by their ```:username```
  - Loads a user's home page, displaying their most recent 100 tweets
  - Returns ```404``` if no user is found

###get '/nanotwitter/v1.0/users/id/:id'
  - Get's a user's username from their ```id``` and redirects to ```/nanotwitter/v1.0/users/:username```

###get '/nanotwitter/v1.0/users/:username/profile'
  - CAN ONLY BE CALLED BY A USER WHO IS LOGGED IN
  - Gets the ```followees``` of the logged in user
  - Loads the logged in user's profile page with a list of their ```followees```

##Post Routes
###post '/nanotwitter/v1.0/users'
  - Creates a new user and logs them in
  - Uses the Sinatra <a href="https://github.com/lyokato/sinatra-formkeeper">Formkeeper</a> gem to validate registration forms
  - If registration fails to validate, redirects to ```/``` and displays an error alert

###post '/nanotwitter/v1.0/users/search'
  - Searches database for users with names or usernames corresponding to ```params[:search]``` search terms
  - Also uses the Sinatra <a href="https://github.com/lyokato/sinatra-formkeeper">Formkeeper</a> gem
  - Loads a search results page with the results

###post '/nanotwitter/v1.0/users/id/:id/tweet'
  - Creates a new tweet and caches it in Redis
  - Redirects back to the request URL

###post '/nanotwitter/v1.0/users/session'
  - Verifies a user's username and password. Stores user's ID in a session cookie.
  - Redirects to ```/```

###post ‘/nanotwitter/v1.0/users/:username/follow'
  - Logged in user begins to follow user ```:username```
  - Redirects back to the request URL

###post ‘/nanotwitter/v1.0/users/:username/unfollow'
  - Logged in user unfollows user ```:username```
  - Redirects back to the request URL

##Test_User Routes for Load Testing
###get '/test_tweet'
  - Has user ```test_user``` tweet a random string using the <a href="https://github.com/stympy/faker">Faker</a> gem
  - Renders the tweet into html and caches it in Redis
  - Does not redirect anywhere

###get '/test_follow'
  - Has user ```test_user``` follow or unfollow a random user from the first 1,000 users in our database

###get '/test_user'
  - Gets the user object for ```test_user``` and the tweets of itself and its ```followees```
  - Loads a user page with those tweets

###get '/reset'
  - Deletes all of ```test_user's``` follow relationships and tweets to reset database between load tests
  - Deletes the Redis cache and redirects to ```/```
