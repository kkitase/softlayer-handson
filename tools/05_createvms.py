#!/usr/bin/env python3
#
# Execute by parent user
# 1. Check image ids for Trend-1032-dsa1(Windows) and Trend-1032-dsa2(Linux)
#    How to check image id
#       slcli image list
#       slcli image detail image_id
# 2. Change number and prefix
# 3. Set the Trend-1032-dsa1(Windows) image ids, hostname and execute
# 4. Set the Trend-1032-dsa2(Linux) image ids, hostname and execute

'''
An example of how to create a VSI from the SL python library
'''
import SoftLayer

n = 20  #change number
prefix = 1031   #change prefix
client = SoftLayer.Client()

instances = []

# using .copy() so we can make changes to individual nodes

for var in range(0, n):
    dic = {}
    dic['domain'] = u'hol.com'
    dic['datacenter'] = u'sjc01'
    dic['dedicated'] = False
    dic['private'] = False
    dic['cpus'] = 2
    dic['image_id'] = u'xxxx-xxxxx-xxxx-xxxxxxxx' # Change image id
    dic['hourly'] = True
    dic['local_disk'] = True
    dic['memory'] = 4096
    dic['nic_speed'] = 100
    dic['tags'] = u'trendmicro'
    dic['hostname'] = str(prefix)+"-dsa2" # Change dsa1 or dsa2
    # dic['post_uri'] = u'https://gist.githubusercontent.com/anonymous/a1eb8120c46023a77227/raw/c236d18e67a257473ab515d09708614d5b617a1f/Locale_Timezone.sh'
    instances.append(dic)
    prefix += 1

mgr = SoftLayer.VSManager(client)
vsi = mgr.create_instances(config_list=instances)

for var in vsi:
    instance_id = var['id']
    user = 'student' + var['hostname'].split("-")[0]
    users = client.call('Account', 'getUsers', mask='id,username')
    user_id = [x['id'] for x in users if x['username'] == user][0]
    client.call(
        'User_Customer',
        'addBulkVirtualGuestAccess',
        [var['id']],
        id=user_id
        )
    prefix += 1

# vsi will be a dictionary of all the new virtual servers
print(vsi)
