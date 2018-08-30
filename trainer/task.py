#! coding: utf-8
import sys
import json
from random import randint, seed

# Загружаем информацию
data = json.loads(sys.argv[1].replace('\\', '').replace('\'', ''))

# Тут из параметров убирается косая черта, так как в Windows двойные
# кавычки требуют экранирования, а в Linux нет. А еще кавычки в Windows
# убираются, а в Linux нет.

mode = data['mode']
config = data['config']
# print(config)
if mode == 'generate':

    # Получем зерно для генератора случайных чисел

    seed(data['seed'])
    maxval1 = int(config["maxval1"])
    maxval2 = int(config["maxval2"])
    gamemode = config["mode"]
    a = randint(0, maxval1)
    b = randint(0, maxval2)
    if gamemode == 'plus':
        question = str(a) + " + " + str(b) + " = ?"
        answer = str(a + b)
    else:
        question = str(a) + " - " + str(b) + " = ?"
        answer = str(a - b)
    print(json.dumps({'question': question, 'answer': answer}))

elif mode == 'check':

    user_answer = data['user_answer']
    answer = data['answer']

    if user_answer == answer:
        print('true')
    else:
        print('false')
