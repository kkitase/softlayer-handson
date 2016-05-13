import SoftLayer
import pprint
pp = pprint.PrettyPrinter(indent=4)

#-----STATUS-----
UPDATEACCOUNT = {'userStatusId': 1001}  #ACTIVE
#UPDATEACCOUNT = {'userStatusId': 1002}  #DISABLED
#UPDATEACCOUNT = {'userStatusId': 1003}  #INACTIVE

#-----STARTWITHKEYWORD for users-----
USER_STARTWITH_KEYWORD="student"
#USER_STARTWITH_KEYWORD="apiuser01"

client = SoftLayer.Client()

print "-----BEFORE-----"
users = client['Account'].getUsers()
for i in users:
    if i['username'].startswith(USER_STARTWITH_KEYWORD):
        print i['username'] + " " + str(i['userStatus'])
        client['User_Customer'].editObject(UPDATEACCOUNT, id=i['id'])

print "-----AFTER-----"
users = client['Account'].getUsers()
for i in users:
    if i['username'].startswith(USER_STARTWITH_KEYWORD):
        print i['username'] + " " + str(i['userStatus'])
