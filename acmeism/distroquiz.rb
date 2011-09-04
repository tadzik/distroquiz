require 'json'

dbfile = 'db.json'

class Question
    attr_accessor :question
    attr_accessor :yes
    attr_accessor :no

    def initialize(question, yes, no)
        @question = question
        @yes      = yes
        @no       = no
    end
end

answers   = {}
questions = {}

data = JSON.parse(IO.read(dbfile))

data['answers'].each do |k, v|
    answers[k] = v
end

data['questions'].each do |k, v|
    yes = v['yes'][0] == "answer" ? lambda { answers[v['yes'][1]]   } \
                                  : lambda { questions[v['yes'][1]] }
    no  = v['no'][0]  == "answer" ? lambda { answers[v['no'][1]]    } \
                                  : lambda { questions[v['no'][1]]  }
    questions[k] = Question.new(v['question'], yes, no)
end

current = questions[data['root']]

while current.is_a?(Question)
    print current.question, ' '
    ans = gets
    if ans.match(/tak/)
        current = current.yes.call
    else
        current = current.no.call
    end
end

puts "Dystrubucje dla Ciebie to mniej-wiecej: ", current.join(', ')
