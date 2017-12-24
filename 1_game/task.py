#! coding: utf-8
import sys
import json
from random import randint, seed

data = json.loads(sys.argv[1])

mode = data['mode']
config = data['config']

if mode == 'generate':
    # Чтобы тестить одну и ту же задачу
    seed(int(1))
    max_size = int(config['max_size'])
    vals_count = int(config['vals_count'])

    question = {}
    question['vals'] = sorted(list([randint(0,max_size) for _ in range(vals_count)]))
    question['heap_size'] = max(question['vals'])*3

    print(json.dumps({'question': question, 'answer': 'answer'}))

elif mode == 'check':
    protocol = json.loads(data['user_answer'])
    print('true')