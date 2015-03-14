# Run this with rake db:seed

User.destroy_all
User.create ([{ name: 'Ari Kalfus', username: 'dev1', password: 'devpass', email: 'dev1@dev.com', phone: '8005555555' }])
User.create ([{ name: 'Aviv Glick', username: 'gaviv', password: '123321', email: 'dev2@dev.com', phone: '3342242' }])
User.create ([{ name: 'Shimon Mazor', username: 'shim', password: '44535', email: 'dev3@dev.com', phone: '4441' }])
User.create ([{ name: 'Toby Gray', username: 'tob', password: '88293', email: 'dev4@dev.com', phone: '22342' }])

user1 = User.find_by username: 'gaviv'
user2 = User.find_by username: 'dev1'
user3 = User.find_by username: 'shim'

Tweet.destroy_all
Tweet.create([{user_id: user2['id'], text: 'First!'}])

Follow.destroy_all
Follow.create([{follower_id: user1['id'], followee_id: user2['id']}])
Follow.create([{follower_id: user1['id'], followee_id: user3['id']}])

