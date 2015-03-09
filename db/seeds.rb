# Run this with rake db:seed

User.destroy_all
User.create ([{ name: 'Ari Kalfus', username: 'dev1', password: 'devpass', email: 'dev1@dev.com', phone: '8005555555' }])

user1 = User.find_by username: 'dev1'

Tweet.destroy_all
Tweet.create([{user_id: user1['id'], text: 'First!'}])

