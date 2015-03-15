require 'faker'

File.open('seed.txt', 'w') do |file| 
	file.write("# Run this with rake db:seed")
	file.write("User.destroy_all\n")
	file.write("#create our users (at :id 1,2,3,4)")
	file.write("\nUser.create ([{ name: 'Ari Kalfus', username: 'dev1', password: 'devpass', email: 'dev1@dev.com', phone: '8005555555', image: 'https://scontent-ord.xx.fbcdn.net/hphotos-xpf1/v/t1.0-9/10690339_10152768150947510_2341191569753235600_n.jpg?oh=bea3e90c4b19f9e74abdca100ee063a4&oe=55855B0C' }])")
	file.write("\nUser.create ([{ name: 'Shimon Mazor', username: 'shiramy', password: '1234567890', email: 'shiramy@gmail.com', phone: '8005555777', image: 'https://scontent-iad.xx.fbcdn.net/hphotos-xaf1/v/t1.0-9/p720x720/10580071_10204378851046860_2286913440271103339_n.jpg?oh=5fe551881244484b0a6afd55213213d5&oe=557D6A4C' }])")
	file.write("\nUser.create ([{ name: 'Aviv Glick', username: 'gaviv', password: '123321', email: 'dev2@dev.com', phone: '3342242', image: 'https://fbcdn-sphotos-f-a.akamaihd.net/hphotos-ak-xfp1/v/t1.0-9/10958924_10152983397638820_4707932385997110852_n.jpg?oh=d486de94df2645d3860e1f1f6d7bcbd0&oe=55B34A90&__gda__=1434012661_d844a039210345cd9cfef75efa8e5321' }])")
	file.write("\nUser.create ([{ name: 'Toby Gray', username: 'tgray', password: '11223344', email: 'devtonby@dev.com', phone: '99322242', image: 'https://fbcdn-sphotos-g-a.akamaihd.net/hphotos-ak-xaf1/v/t1.0-9/15411_10204653461433290_4531476834591487136_n.jpg?oh=f48ad07f596f8709ae0263b2ede76f1b&oe=5576F6AA&__gda__=1433519828_c4dc52cbec6ceafdcffb08d86c409b3e' }])")

	file.write("\n\n")
	file.write("#Now we want to create 10 users :id 5,6,7,8,9,10,11,12,13,14\n")
	file.write("User.create([")
	
	arr = []
	(0..10).each do |i|
		if i>0 then
			file.write(",\n")
		end
		name = Faker::Name.name
		username = Faker::Internet.user_name("#{name}", %w(. _ -))
		arr << username
		email = Faker::Internet.email(username)
		phone = Faker::PhoneNumber.phone_number
		password = Faker::Internet.password(8)
		image = Faker::Avatar.image
		file.write("{name:'#{name}', username:'#{username}', password:'#{password}', email:'#{email}', phone:'#{phone}', image:'#{image}' }")
	end
	file.write("])\n\n")
	
	file.write("#Now we want to create 10 tweets for our 10 fake users. Tweet :id 1,2,3,4,5,6,7,8,9,10")
	file.write("\nTweet.destroy_all")
	file.write("\nTweet.create([")

	(0..10).each do |i|
		if i>0 then
			file.write(",\n")
		end
		text = Faker::Hacker.say_something_smart

		file.write("{user_id:#{i+5}, text:\"#{text}\"}")

	end
	file.write("])\n\n")

end


