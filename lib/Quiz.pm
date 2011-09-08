#the Perl 6 version is way prettier :)
{
    package Quiz;
    use 5.012;
    use encoding 'utf8';
    use JSON::XS;
    use File::Slurp 'slurp';

    use Mo;
    has 'db';
    has 'states'; # int -> id pytania
    has 'questions'; # id pytania -> obiekt Question
    has 'answers';

    {
        package Question;
        use Mo;
        has 'state';
        has 'question';
        has 'yes';
        has 'no';
    }

    sub BUILD {
        my $self = shift;
        # defaults
        $self->db // $self->db('db.json');
        $self->states([]);
        $self->questions({});
        $self->answers({});

        my $data = decode_json(slurp($self->db));
        my $stateiter = 1;

        while (my ($k, $v) = each %{$data->{'answers'}}) {
            $self->answers->{$k} = $v;
        }

        while (my ($k, $v) = each %{$data->{'questions'}}) {
            my $q = Question->new(
                question => $v->{'question'},
                yes      => $v->{'yes'},
                no       => $v->{'no'},
                state    => $stateiter,
            );
            $self->states->[$stateiter] = $q;
            $self->questions->{$k}      = $q;
            $stateiter++;
        }

        $self->states->[0] = $self->questions->{$data->{'root'}};
    }

    # given the present state returns the question to ask
    # args    ($current-state)
    # returns ($question [string])
    sub ask {
        my ($self, $state) = @_;
        my $q = $self->states->[$state];
        return unless $q;
        return $q->question;
    }

    # args    ($current-state, $answer)
    # returns ($next-state OR arrayref with distros)
    sub answer {
        my ($self, $state, $yesno) = @_;
        my $lastq    = $self->states->[$state];
        my $res      = $yesno ? $lastq->yes : $lastq->no;
        if ($res->[0] eq 'question') {
            return $self->questions->{$res->[1]}->state;
        } else {
            return $self->answers->{$res->[1]};
        }
    }
}
