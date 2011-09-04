use Mojolicious::Lite;
use lib 'lib';
use Quiz;

my $quiz = Quiz->new;

get '/' => sub {
    shift->redirect_to('state/0');
};

get '/state/:state' => sub {
    my $self     = shift;
    my $state    = $self->param('state');
    my $question = $quiz->ask($state);

    $self->stash(state    => $state);
    $self->stash(question => $question);
    $self->render('question');
};

get '/answer/:state/:yesno' => sub {
    my $self  = shift;
    my $state = $self->param('state');
    my $yesno = $self->param('yesno');
    my $res = $quiz->answer($state, $yesno);
    if (ref $res eq 'ARRAY') {
        my $ans = join ", ", @$res;
        $self->stash(answer => $ans);
        $self->render('answer');
    } else {
        $self->redirect_to("state/$res");
    }
};

app->start;

__DATA__

@@ question.html.ep
<!doctype html><html>
  <head><title>Pytanie</title></head>
  <body>
    <%= $question %><br />
    <a href='/answer/<%= $state =%>/1'>Tak</a><br />
    <a href='/answer/<%= $state =%>/0'>Nie</a><br />
  </body>
</html>

@@ question.json.ep
{ 'question' : '<%= $question =%>' }

@@ answer.html.ep
<!doctype html><html>
  <head><title>Odpowiedź</title></head>
  <body>
    <%= $answer %>
  </body>
</html>

@@ answer.json.ep
{ 'answer' : '<%= $answer =%>' }
