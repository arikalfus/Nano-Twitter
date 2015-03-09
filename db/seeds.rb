# Run this with rake db:seed

User.destroy_all
User.create ([{ name: 'Ari Kalfus', username: 'dev1', password: 'devpass', email: 'dev1@dev.com', phone: '8005555555' }])

user = User.where(username: 'dev1').take

Tweet.destroy_all
Tweet.create([{user_id: user['id'], text: 'First!'}])

