# Nano-Twitter 
Project focusing on load testing for COSI 105B: Architecture at Scale at Brandeis University.

<img alt="Status?branch=master" src="https://codeship.com/projects/50007a90-ae63-0132-7ed9-2ecd9a04cc80/status?branch=master" />

# Route descriptions

get '/'
Makes sure the login cookie is valid
Shows the current homepage, depending on whether or not the user is logged in or not. 
Gets the 25 most recent tweets, random if not logged in, from the users follows if they are logged in. 
user is the stored user in the session (if there is one) otherwise they are not logged in. 

get '/logout'

pulls 25 tweets
loads the root home page, passing the local variables (tweets) which is a list of those 25 tweets and their users, and a logout boolean of true, so that the root page displays as logged out not logged in. 

get '/nanotwitter/v1.0/logout'
deletes the session cookie then redirects to /logout

get '/nanotwitter/v1.0/users/:username'
Finds by username a user and loads that user page, which is a list of that users tweets
If there is no user returns 404 found no user

get '/nanotwitter/v1.0/users/id/:id'
Finds the user and then redirects to '/nanotwitter/v1.0/users/:username'

get ‘nanotwitter/v1.0/users/:username/profile
If the user is logged in, displays a users private profile page

post '/nanotwitter/v1.0/users'
Creates a new user with parameters name, password, username, email, and phone. If the user is valid it stores that user in the session, and redirects back to the previous page
Otherwise it returns an error 400. 

post '/nanotwitter/v1.0/users/id/:id/tweet
creates a new tweet with parameters of the text of the tweet and the users id of which it belongs. 
If the tweet is valid it posts it and redirects back to the page it was posted on, since tweets can be posted from several locations. 
If the tweet is not valid, error 400

post '/nanotwitter/v1.0/users/session'
Verifies a user by their password. If they are the right user it redirects to the root page. Else it redirects to the not logged in root page and says invalid login credentials (error 400)


post ‘/nanotwitter/v1.0/users/:username/follow
follows the user :username

post ‘/nanotwitter/v1.0/users/:username/unfollow
unfollows the user, :username


put '/nanotwitter/v1.0/users/id/:id'
Updates an existing user using their user id. 
Finds the user, and if not found returns an error 404 user not found. Then tries to update by parsing the json of the user, if this fails it returns an error 400. 

