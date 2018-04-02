import redis
import time
import json
import pprint

events = [
    'DNS::Tunneling',
    'Struts::Attempt',
    'NewModule',
    'Secret::Extract',
]

real_time_evt_list = []

def emit(event):
    #print(event)
    real_time_evt_list.append(event)
    print('CURRENT EVENT: ', event)
    print('ACCUMULATIVE REAL TIME EVENT: ', real_time_evt_list)
    pass

r = redis.StrictRedis(host='localhost', port=6379)
p = r.pubsub()
p.subscribe('filebeat')

for item in p.listen():
    data = item['data']
    if (isinstance(data, int)):
        continue
    data = json.loads(data.decode('utf-8'))

    if 'note' in data:
        if data['note'] == 'Struts::Attempt':
            emit('Struts::Attempt')
            continue
    if 'note' in data:
        if data['note'] in ['DNS::Tunneling', 'DNS::Oversized_Answer', 'DNS::Oversized_Query']:
            emit('DNS::Tunneling')
            continue
    '''
    if data['action'] == 'added' and data['jfldskjsl']
        emit('Kernel::Newmodule')
        continue
    '''
    if 'name' in data:
        #print("The data hs name field!")
        if data['name'] == 'kernel_module':
            if data['action'] == 'added':
                emit('Kernel::NewmoduleAdded')
                continue
            elif data['action'] == 'removed':
                emit('Kernel::ModuleRemoved')
                continue
        #print('name is: ', data['name'])
        elif data['name'] == 'pack_file-accesses_file_events':
            #print("The event is: ", data['name'])
            col_act = data['columns']['action']
            #print("Col Action field: ", col_act)
            if col_act != None:
                #print("Col action is not none!")
                if col_act == 'OPENED' or col_act == 'ACCESSED' or col_act == 'UPDATED' or col_act == 'DELETED':
                    emit('Secret::Extract'+' @ '+data['columns']['target_path'])
                    #pprint.pprint(data)
    '''
    if data['action'] == 'read':
        emit('Secret::Extract')
        continue
    '''
   
    pprint.pprint(data)
