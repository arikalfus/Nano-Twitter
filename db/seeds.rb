# Run this with rake db:seed

User.destroy_all
User.create ([{ name: 'Ari Kalfus', username: 'dev1', password: 'devpass', email: 'dev1@dev.com', phone: '8005555555' }])
<<<<<<< HEAD
User.create ([{ name: 'Shimon Mazor', username: 'shiramy', password: '1234567890', email: 'shiramy@gmail.com', phone: '8005555777' }])
=======
User.create ([{ name: 'Aviv Glick', username: 'gaviv', password: '123321', email: 'dev2@dev.com', phone: '3342242' }])
>>>>>>> master

user1 = User.find_by username: 'dev1'

Tweet.destroy_all
Tweet.create([{user_id: user1['id'], text: 'First!'}])

