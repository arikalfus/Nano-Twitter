# Run this with rake db:seed
User.destroy_all
#create our users (at :id 1,2,3,4)
User.create ([{ name: 'Ari Kalfus', username: 'dev1', password: 'devpass', email: 'dev1@dev.com', phone: '8005555555', image: 'https://scontent-ord.xx.fbcdn.net/hphotos-xpf1/v/t1.0-9/10690339_10152768150947510_2341191569753235600_n.jpg?oh=bea3e90c4b19f9e74abdca100ee063a4&oe=55855B0C' }])
User.create ([{ name: 'Shimon Mazor', username: 'shiramy', password: '1234567890', email: 'shiramy@gmail.com', phone: '8005555777', image: 'https://scontent-iad.xx.fbcdn.net/hphotos-xaf1/v/t1.0-9/p720x720/10580071_10204378851046860_2286913440271103339_n.jpg?oh=5fe551881244484b0a6afd55213213d5&oe=557D6A4C' }])
User.create ([{ name: 'Aviv Glick', username: 'gaviv', password: '123321', email: 'dev2@dev.com', phone: '3342242', image: 'https://fbcdn-sphotos-f-a.akamaihd.net/hphotos-ak-xfp1/v/t1.0-9/10958924_10152983397638820_4707932385997110852_n.jpg?oh=d486de94df2645d3860e1f1f6d7bcbd0&oe=55B34A90&__gda__=1434012661_d844a039210345cd9cfef75efa8e5321' }])
User.create ([{ name: 'Toby Gray', username: 'tgray', password: '11223344', email: 'devtonby@dev.com', phone: '99322242', image: 'https://fbcdn-sphotos-g-a.akamaihd.net/hphotos-ak-xaf1/v/t1.0-9/15411_10204653461433290_4531476834591487136_n.jpg?oh=f48ad07f596f8709ae0263b2ede76f1b&oe=5576F6AA&__gda__=1433519828_c4dc52cbec6ceafdcffb08d86c409b3e' }])

#Now we want to create 10 users :id 5,6,7,8,9,10,11,12,13,14
User.create([{name:'Avis Ernser', username:'avis-ernser', password:'u60xmymes', email:'avis.ernser@kling.info', phone:'106-264-9962 x633', image:'http://robohash.org/commodiverout.png?size=300x300' },
{name:'Miss Nasir Sipes', username:'sipes-nasir-miss', password:'yp15iids2', email:'nasir.sipes.miss@kshlerin.net', phone:'1-764-740-8747 x85294', image:'http://robohash.org/eosquoeveniet.png?size=300x300' },
{name:'Alvera Kris', username:'alvera_kris', password:'12z21qitd', email:'alvera_kris@gleason.net', phone:'1-918-354-4735', image:'http://robohash.org/estetnecessitatibus.png?size=300x300' },
{name:'Cheyanne Stroman', username:'cheyanne-stroman', password:'uodzsyj23', email:'stroman_cheyanne@kemmer.name', phone:'315.847.6716', image:'http://robohash.org/veritatisfugitvelit.png?size=300x300' },
{name:'Kyla Bahringer', username:'bahringer.kyla', password:'mdgws2hw9', email:'kyla.bahringer@blandastamm.biz', phone:'133-849-2262 x6948', image:'http://robohash.org/namaccusantiumnecessitatibus.png?size=300x300' },
{name:'Desmond Witting', username:'desmond-witting', password:'oikca1ayj', email:'witting_desmond@andersongibson.net', phone:'1-164-790-6498 x756', image:'http://robohash.org/utmolestiaeexercitationem.png?size=300x300' },
{name:'Yessenia Johnston', username:'yessenia_johnston', password:'zp8cqhamx', email:'yessenia_johnston@batzdenesik.info', phone:'575.103.4701', image:'http://robohash.org/doloressedodio.png?size=300x300' },
{name:'Esmeralda Berge', username:'berge-esmeralda', password:'g5kyee70', email:'berge.esmeralda@vonrunte.org', phone:'201-509-7044 x016', image:'http://robohash.org/consequaturquaeratnatus.png?size=300x300' },
{name:'Jayden Moore', username:'jayden.moore', password:'n4csise5z', email:'jayden.moore@sipes.info', phone:'(203) 111-1515', image:'http://robohash.org/sunteiusvoluptate.png?size=300x300' },
{name:'Gordon Gaylord', username:'gaylord_gordon', password:'zbvs3vom', email:'gaylord_gordon@feesthills.net', phone:'1-313-366-4678', image:'http://robohash.org/veroquisint.png?size=300x300' },
{name:'Christian Murray', username:'christian.murray', password:'tl3kwjgns', email:'christian_murray@krajcik.info', phone:'(747) 545-4939 x161', image:'http://robohash.org/eaquevoluptatemamet.png?size=300x300' }])

#Now we want to create 10 tweets for our 10 fake users. Tweet :id 1,2,3,4,5,6,7,8,9,10
Tweet.destroy_all
Tweet.create([{user_id:5, text: 'Try to parse the GB interface, maybe it will navigate the bluetooth sensor!' },
{user_id:6, text:"I'll input the back-end XML monitor, that should bandwidth the SMTP bus!"},
{user_id:7, text: 'The SAS protocol is down, synthesize the primary array so we can connect the EXE bus!' },
{user_id:8, text: 'The COM firewall is down, calculate the online feed so we can hack the COM circuit!' },
{user_id:9, text:"programming the bus won't do anything, we need to input the auxiliary USB circuit!"},
{user_id:10, text:"transmitting the protocol won't do anything, we need to synthesize the haptic JBOD program!"},
{user_id:11, text: 'The AGP card is down, generate the neural firewall so we can generate the SSL monitor!' },
{user_id:12, text:"I'll hack the redundant HTTP application, that should firewall the RSS application!"},
{user_id:13, text: 'If we quantify the alarm, we can get to the JSON array through the bluetooth THX protocol!' },
{user_id:14, text: 'Use the 1080p SSL panel, then you can reboot the solid state circuit!' },
{user_id:15, text: 'Use the wireless EXE array, then you can back up the auxiliary port!' },
{user_id: 1, text: 'First!'}])

# just some people shimon follows
x = User.find_by(username:'shiramy')

x.followees << User.find(5)
x.followees << User.find(1)
x.followees << User.find(3)
x.followees << User.find(4)

y = User.find_by(username:'dev1')

y.followees << User.find(5)
y.followees << User.find(2)
y.followees << User.find(3)
y.followees << User.find(4)

z = User.find_by(username:'gaviv')

z.followees << User.find(5)
z.followees << User.find(1)
z.followees << User.find(2)
z.followees << User.find(4)

t = User.find_by(username:'tgray')

t.followees << User.find(5)
t.followees << User.find(2)
t.followees << User.find(3)
t.followees << User.find(1)

