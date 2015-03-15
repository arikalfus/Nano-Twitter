# Run this with rake db:seedUser.destroy_all
#create our users (at :id 1,2,3,4)
User.create ([{ name: 'Ari Kalfus', username: 'dev1', password: 'devpass', email: 'dev1@dev.com', phone: '8005555555' }])
User.create ([{ name: 'Shimon Mazor', username: 'shiramy', password: '1234567890', email: 'shiramy@gmail.com', phone: '8005555777' }])
User.create ([{ name: 'Aviv Glick', username: 'gaviv', password: '123321', email: 'dev2@dev.com', phone: '3342242' }])
<<<<<<< HEAD
User.create ([{ name: 'Toby Gray', username: 'tgray', password: '11223344', email: 'devtonby@dev.com', phone: '99322242' }])

#Now we want to create 10 users :id 5,6,7,8,9,10,11,12,13,14
User.create([{name:'Rupert Bauch', username:'rupert.bauch', password:'wdi7i9n44', email:'bauch.rupert@lakin.org', phone:'813-633-7785 x54623'},
{name:'Edythe Cruickshank', username:'edythe.cruickshank', password:'tyd3fcb69', email:'edythe.cruickshank@blick.net', phone:'(711) 575-5705 x60341'},
{name:'Lorine Armstrong', username:'armstrong.lorine', password:'324c24rxo', email:'lorine.armstrong@schimmel.biz', phone:'(150) 095-0197'},
{name:'Eldridge Goodwin III', username:'goodwin-iii-eldridge', password:'x0b3czwbr', email:'iii_goodwin_eldridge@sawayn.net', phone:'306-656-9645 x96115'},
{name:'Melody Nitzsche', username:'nitzsche_melody', password:'kjav66thi', email:'nitzsche_melody@crooks.net', phone:'(250) 542-1849 x888'},
{name:'Marlen Torphy', username:'marlen-torphy', password:'4hgz2o5ee', email:'torphy.marlen@rogahn.biz', phone:'1-182-680-5989 x405'},
{name:'Dr. Ava Williamson', username:'williamson-dr-ava', password:'l639jvv5f', email:'dr.williamson.ava@mclaughlin.com', phone:'(229) 135-4462'},
{name:'Ms. Edmond Weissnat', username:'edmond_ms_weissnat', password:'le2rnrxe5', email:'edmond_ms_weissnat@will.net', phone:'637-449-0975'},
{name:'Albertha Heller', username:'albertha-heller', password:'p0ahd6znz', email:'heller_albertha@rowe.org', phone:'(881) 517-6871'},
{name:'Jeanette Keebler PhD', username:'phd-jeanette-keebler', password:'0qijq64ez', email:'phd.keebler.jeanette@hilll.info', phone:'964.746.5966 x589'},
{name:'Mina Schuppe', username:'mina.schuppe', password:'rfyufxug0', email:'mina_schuppe@macejkovic.com', phone:'1-665-079-8314 x013'}])
=======
User.create ([{ name: 'Shimon Mazor', username: 'shim', password: '44535', email: 'dev3@dev.com', phone: '4441' }])
User.create ([{ name: 'Toby Gray', username: 'tob', password: '88293', email: 'dev4@dev.com', phone: '22342' }])

user1 = User.find_by username: 'gaviv'
user2 = User.find_by username: 'dev1'
user3 = User.find_by username: 'shim'
>>>>>>> master

#Now we want to create 10 tweets for our 10 fake users. Tweet :id 1,2,3,4,5,6,7,8,9,10
Tweet.destroy_all
<<<<<<< HEAD
Tweet.create([{user_id:5, text:"You can't copy the driver without quantifying the virtual PNG feed!"},
{user_id:6, text:"If we reboot the sensor, we can get to the SCSI sensor through the redundant SMS panel!"},
{user_id:7, text:"The IB bandwidth is down, reboot the optical hard drive so we can transmit the EXE interface!"},
{user_id:8, text:"programming the interface won't do anything, we need to input the primary HTTP port!"},
{user_id:9, text:"If we copy the array, we can get to the USB application through the cross-platform JSON matrix!"},
{user_id:10, text:"The JSON program is down, connect the open-source pixel so we can input the PCI array!"},
{user_id:11, text:"We need to quantify the redundant HDD bandwidth!"},
{user_id:12, text:"The SQL protocol is down, hack the bluetooth capacitor so we can calculate the IB array!"},
{user_id:13, text:"If we hack the matrix, we can get to the AI array through the primary RAM card!"},
{user_id:14, text:"The SCSI hard drive is down, navigate the back-end interface so we can generate the THX circuit!"},
{user_id:15, text:"Try to copy the SMS hard drive, maybe it will bypass the multi-byte application!"}])
=======
Tweet.create([{user_id: user2['id'], text: 'First!'}])

Follow.destroy_all
Follow.create([{follower_id: user1['id'], followee_id: user2['id']}])
Follow.create([{follower_id: user1['id'], followee_id: user3['id']}])
>>>>>>> master

