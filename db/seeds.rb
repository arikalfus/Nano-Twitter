#Run this with rake db:seed

#ari can you see this?
User.destroy_all
#User.create (some users)

bla = User.where(name:'bla').take #takes the first one

Tweet.destroy_all
#Tweet.create([{name:'bla', email: 'bla@example.com'},{}])

