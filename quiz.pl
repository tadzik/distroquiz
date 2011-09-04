use 5.012;
use lib 'lib';
use Quiz;

my $app = Quiz->new;
my $state = 0;

while (1) {
    say $app->ask($state), " ";
    my $ans = $app->answer($state, (<> ~~ /tak/));
    if (ref $ans eq 'ARRAY') {
        say join ", ", @$ans;
        exit 0;
    } else {
        $state   = $ans;
    }
}
