#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

use Log::Log4perl;
use Plack::Test;
use Plack::Builder;
use Plack::Middleware::Debug::Log4perl;
use HTTP::Request::Common;

my $content_type = 'text/html'; # ('text/html', 'text/html; charset=utf8',);


note "Content-Type: $content_type";
my $app = sub {
    my $logger = Log::Log4perl->get_logger("test.app");
    $logger->info("Starting Test App");
    foreach my $i (1..20) {
      $logger->debug("Counter is: $i");
    }
    $logger->info("All Done - Thanks for Visiting");
    return [
        200, [ 'Content-Type' => $content_type ],
        ['<body>Hello World</body>']
    ];
};
$app = builder {
    enable 'Debug', panels =>[qw/Response Memory Timer Log4perl/];
    $app;
};
test_psgi $app, sub {
    my $cb  = shift;
    my $res = $cb->(GET '/');
    is $res->code, 200, 'response status 200';
    for my $panel (qw/Response Memory Timer Log4perl/) {
        like $res->content,
          qr/<a href="#" title="$panel" class="plDebug${panel}\d+Panel">/,
          "HTML contains $panel panel";
    }
};

done_testing;

