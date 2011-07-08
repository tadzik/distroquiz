#the Perl 6 version is way prettier :)

{
    package Question;
    use Moo;
    has question => ( is => 'ro' );
    has yes      => ( is => 'ro' );
    has no       => ( is => 'ro' );
}

use 5.012;
use JSON::XS;
use File::Slurp 'slurp';
use encoding 'utf8';

my $data = decode_json slurp 'db.json';
my %answers;
my %questions;

while (my ($k, $v) = each %{$data->{'answers'}}) {
    $answers{$k} = $v;
}

while (my ($k, $v) = each %{$data->{'questions'}}) {
    $questions{$k} = Question->new(
        question => $v->{'question'},
        yes      => $v->{'yes'}[0] eq 'answer'
                     ? sub { $answers{$v->{'yes'}[1]} }
                     : sub { $questions{$v->{'yes'}[1]} },
        no       => $v->{'no'}[0] eq 'answer'
                     ? sub { $answers{$v->{'no'}[1]} }
                     : sub { $questions{$v->{'no'}[1]} },
    );
}

my $current = $questions{$data->{'root'}};

while (ref $current ne 'ARRAY') {
    print $current->question, " ";
    if (<> ~~ /tak/) {
        $current = $current->yes->();
    } else {
        $current = $current->no->();
    }
}

say "Dystrybucje dla Ciebie to mniej-więcej: ", join(', ', @$current);
