#sudo apt-get install python-facebook
#source http://stackoverflow.com/a/5191033
from facebook import Facebook
#creat app via visiting https://developers.facebook.com/apps and get below keys
api_key = '273762xxxxxxxx'
secret  = 'dffc85xxxxxxxxxxxxxxxxx'

session_key = '451XXX'
#session_onetime_code = 'LX2XXX'

ga = Facebook(api_key, secret)
ga.session_key = session_key

# now use the ga object for playing around
#You might need to get an infinite session key which you can get from here: http://www.facebook.com/code_gen.php?v=1.0&api_key=YOUR_API_KEY

#Use this code to get convert the code from above URL into infinite session key:

def generate_session_from_onetime_code(ga, code):
    ga.auth_token = code
    return ga.auth.getSession()
print generate_session_from_onetime_code(ga, session_key)

print ga


#sourch http://blog.chmouel.com/2010/01/09/get-facebook-albums-with-python/
import os
import urllib
#ga.auth.createToken()
#ga.login()
#ga.auth.getSession()

def choose_albums(ga):
    cnt = 1
    ret={}
    bigthing=ga.photos.getAlbums(ga.uid)
 
    for row in bigthing:
        ret[cnt] = row['name'], row['aid'], row['link']
        print "%d) %s - %s" % (cnt, row['name'], row['link'])
        cnt += 1
    ans = raw_input("Choose albums (separated by ,): ")
    return [ret[int(row)] for row in ans.split(', ') ]
 
chosen_albums = choose_albums(ga)
for album in chosen_albums:
    name, aid, _ =  album
    print "Album: ", (name)
    ddir = "gagallery/%s" % name
    if not os.path.exists(ddir):
        os.makedirs(ddir)
    for photo in ga.photos.get(aid=aid):
        url = photo['src_big']
        dest="%s/%s.jpg" % (ddir, photo['pid'])
        if not os.path.exists(dest):
            print "Getting: ", url
            urllib.urlretrieve(url, dest)

#Problem solved with svn checkout http://photograbber.googlecode.com/svn/trunk/ photograbber-read-only
#cd photograbber-read-only/
#./pg.py
#edit line 171 of above to '.' local directory

