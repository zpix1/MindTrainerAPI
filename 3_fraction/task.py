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
    question['vals'] = sorted(list([(1,randint(2,max_size)) for _ in range(vals_count)]))

    print(json.dumps({'question': question, 'answer': 'answer'}))

elif mode == 'check':
    protocol = json.loads(data['user_answer'])
    print('true')