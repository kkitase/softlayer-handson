#!/usr/bin/env python3
#
# This is the scripts to delete all servers and change password for provided users
# execute by super user e.g. SLxxxxxx
# e.g. python delete.py --prefix userid1001 --password hogehogehoge

import SoftLayer.API
from pprint import pprint as pp

def get_target_users(prefix):
    _filter = {
        'users': {
            'username': {
                'operation': '*= %s' % (prefix)
            }
        }
    }
    _mask = "mask[id,username]"
    _users = client['Account'].getUsers(filter=_filter, mask=_mask)
    return _users

def get_target_keys(prefix):
    _filter = {
        'sshKeys': {
            'label': {
                'operation': '*= %s' % (prefix)
            }
        }
    }

    _mask = "mask[id,label]"
    _users = client['Account'].getSshKeys(filter=_filter, mask=_mask)
    return _users

def print_result(result, thing):
    if result == True:
        print "OK"
    else:
        print "ERROR: "
        pp(thing)
    return

if __name__ == "__main__":
    import argparse
    argsparse = argparse.ArgumentParser(description='Number of users')
    argsparse.add_argument('--prefix',
                           help='Username prefix', default=False)
    argsparse.add_argument('--password',
                           help='New Password', default=False)

    args = argsparse.parse_args()

    client = SoftLayer.Client()

    users = get_target_users(args.prefix)

    for user in users:
        password =  args.password
        print 'User: ' + user['username'] + ' Password: ' + password
        # status 1021 disables the user
        template = {
            'id': user['id'],
            'userStatusId': 1021
        }

        # Cancel any servers the user created
        servers = client['User_Customer'].getVirtualGuests(id=user['id'])
        result = True
        for virt in servers:
            # the "," and the end of print removes the automatic newline
            print("\tCanceling host... " + virt['fullyQualifiedDomainName'] + " (" + str(virt['id']) + ")\t"),
            try:
                result = client['Virtual_Guest'].deleteObject(id=virt['id'])
                print_result(result,virt)
            except SoftLayer.exceptions.SoftLayerAPIError as error:
                print("\tException, host might already be canceling...")
                pp(error)

        print("\tChanging password for..." + user['username'] + " (" + str(user['id']) + ")\t"),
        result = client['User_Customer'].updatePassword(password, id=user['id'])
        print_result(result,user)

    sshkeys = get_target_keys(args.prefix)
    print 'SSH Key Removal'
    for key in sshkeys:
        print("Deleting key... " + key['label'] + " (" + str(key['id']) + ")\t"),
        result = client['SoftLayer_Security_Ssh_Key'].deleteObject(id=key['id'])
        print_result(result,key)

    print 'Complete'
