import SoftLayer
import sys, pprint
pp = pprint.PrettyPrinter(indent=4)

#-----PASSWORD-----
NEW_PASSWORD="hogehoge"

#-----STARTWITHKEYWORD for users-----
USER_STARTWITH_KEYWORD="student"
#USER_STARTWITH_KEYWORD="apiuser01"


client = SoftLayer.Client()

#Check if the current user is MasterUser
currentUser=client['Account'].getCurrentUser()
if not client['User_Customer'].isMasterUser(id=currentUser['id']):
        print "ERROR_00255 : This user is not Master User. "
        sys.exit(255)


print "-----Update Password------"
print "new password     : " + NEW_PASSWORD


users = client['Account'].getUsers()
for i in users:
    if i['username'].startswith(USER_STARTWITH_KEYWORD):

        #Check if new password is already used
        isValidNewPassword = client['User_Customer'].isValidPortalPassword(NEW_PASSWORD, id=i['id'])
        if isValidNewPassword:
                print "The new password is already used"
                continue

        #Update Password
        client['User_Customer'].updatePassword(NEW_PASSWORD, id=i['id'])

        #Check if new password is valid
        isValidNewPassword = client['User_Customer'].isValidPortalPassword(NEW_PASSWORD, id=i['id'])
        print "NEW    : username: " + i['username'] + " : Password Check Result : " + str(isValidNewPassword)
