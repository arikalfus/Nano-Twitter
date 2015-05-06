require 'csv'
require 'faker'

File.open('new_seed_short.rb', 'w') do |file| 
	file.write("# Run this with rake db:seed")
	file.write("\nUser.destroy_all")
	file.write("\n#create Nick's users (at :id 1,2,3,4,...,1000)")
	#file.write("\nUser.create([")
	i = 0
	#first load and parse users.csv
	CSV.foreach("users_short.csv") do |row|
		#if i>0 then
		#	file.write(",\n")
		#end
		name = row[1]
		email = Faker::Internet.email(name)
		phone = Faker::PhoneNumber.phone_number
		password = Faker::Internet.password(8)
		image = Faker::Avatar.image
		file.write("\nUser.create({name:\"#{name}\", username:\"#{name}\", password:'#{password}', email:'#{email}', phone:'#{phone}', image:'#{image}' })")
		i+=1
	end
	#file.write("])\n\n")

	file.write("#create our users (at :id 1001,1002,1003,1004)")
	file.write("\nUser.create ([{ name: 'Ari Kalfus', username: 'dev1', password: 'devpass', email: 'dev1@dev.com', phone: '8005555555', image: 'https://scontent-ord.xx.fbcdn.net/hphotos-xpf1/v/t1.0-9/10690339_10152768150947510_2341191569753235600_n.jpg?oh=bea3e90c4b19f9e74abdca100ee063a4&oe=55855B0C' }])")
	file.write("\nUser.create ([{ name: 'Shimon Mazor', username: 'shiramy', password: '1234567890', email: 'shiramy@gmail.com', phone: '8005555777', image: 'https://scontent-iad.xx.fbcdn.net/hphotos-xaf1/v/t1.0-9/p720x720/10580071_10204378851046860_2286913440271103339_n.jpg?oh=5fe551881244484b0a6afd55213213d5&oe=557D6A4C' }])")
	file.write("\nUser.create ([{ name: 'Aviv Glick', username: 'gaviv', password: '123321', email: 'dev2@dev.com', phone: '3342242', image: 'https://fbcdn-sphotos-f-a.akamaihd.net/hphotos-ak-xfp1/v/t1.0-9/10958924_10152983397638820_4707932385997110852_n.jpg?oh=d486de94df2645d3860e1f1f6d7bcbd0&oe=55B34A90&__gda__=1434012661_d844a039210345cd9cfef75efa8e5321' }])")
	file.write("\nUser.create ([{ name: 'Toby Gray', username: 'tgray', password: '11223344', email: 'devtonby@dev.com', phone: '99322242', image: 'https://fbcdn-sphotos-g-a.akamaihd.net/hphotos-ak-xaf1/v/t1.0-9/15411_10204653461433290_4531476834591487136_n.jpg?oh=f48ad07f596f8709ae0263b2ede76f1b&oe=5576F6AA&__gda__=1433519828_c4dc52cbec6ceafdcffb08d86c409b3e' }])")
	file.write("\n\n")

	file.write("#Now we want to create 0-200 tweets per user (average 100) Tweet :id 1,2,3,4,...,200")
	file.write("\nTweet.destroy_all")
	#file.write("\nTweet.create([")

	i=0
	#second load and parse tweets.csv
	CSV.foreach("tweets_short.csv") do |row|
		#if i>0 then
		#	file.write(",\n")
		#end
		user_id = row[0]
		text = row[1]
		created_at = row[2]
		updated_at = row[2]
		file.write("\nTweet.create({user_id:#{user_id}, text:\"#{text}\", created_at:\"#{created_at}\", updated_at:\"#{updated_at}\"})")
		i+=1
	end
	#file.write("])\n\n")

	
	file.write("\n#Processing follows.csv")
	file.write("\nFollow.destroy_all")
	#file.write("\nFollow.create([")
	#third load and parse follows.csv : id1,id2 where id1 follows id2
	i=0
	#second load and parse tweets.csv
	CSV.foreach("follows_short.csv") do |row|
		#if i>0 then
		#	file.write(",\n")
		#end
		follower_id = row[0]
		followee_id = row[1]
		file.write("\nFollow.create({follower_id:#{follower_id}, followee_id:#{followee_id}})")
		i+=1
	end
	#file.write("])\n\n")
end
