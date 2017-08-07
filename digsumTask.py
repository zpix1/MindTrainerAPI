import sys # Для доступа к аргументам командной строки
import json # Для парсинга JSON
from random import randint,seed # Для генерации цифр

mode = sys.argv[1] # Получем режим
if mode == 'generate': # Если надо сгенерировать задачу
    config = json.loads(sys.argv[2]) # Получаем конфигурацию
    s = int(sys.argv[3]) # Получем зерно для генератора случайных чисел
    seed(s) # Используем это зерно
    maxval = config["maxval"]
    a = randint(0, maxval) # Генерируем цифры для сложения
    b = randint(0, maxval)
    question = str(a) + " + " + str(b) + " = ?" # Вопрос
    answer = str(a+b) # Ответ
    print(json.dumps({'question':question,'answer':answer}))
elif mode == 'check': # Если надо проверить
    user_answer = int(sys.argv[2]) # Считываем ответ пользователя и настоящий ответ
    answer = int(sys.argv[3])
    if user_answer == answer: # Если правильно, то пишем true, иначе false
        print('true')
    else:
        print('false')