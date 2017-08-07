TRAINER_NAME = 'digsum'
def get_task(task)
    cmd = "timeout 2 python #{Rails.root}/lib/trainers/#{TRAINER_NAME}/#{TRAINER_NAME}Task.py generate '#{JSON.generate(task[:config])}' '#{task.seed % 30000}'"
    ans = `#{cmd}`
    result = JSON.parse ans
    task.question = result['question']
    task.answer = result['answer']
    return task
end

def check_task(task)
    cmd = "timeout 2 python #{Rails.root}/lib/trainers/#{TRAINER_NAME}/#{TRAINER_NAME}Task.py check '#{task.user_answer}' '#{task.answer}' '#{task.seed % 30000}'"
    ans = `#{cmd}`
    ans.chomp == 'true'
end
