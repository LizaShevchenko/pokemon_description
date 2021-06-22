#!/usr/bin/env perl
use HTTP::Request;
use JSON::XS;
use LWP::Protocol::https;
use LWP::UserAgent;
use Mojolicious::Lite -signatures;
use Readonly;
use Try::Tiny;
use lib 'lib';
use PokemonModule;

=head1 Usage
 $ ./pokemon.pl daemon -M  production -l http://*:8080
 > curl http://localhost:8080/pokemon/pikachu
=cut


get '/healthcheck' => sub ($c) {
    my $result = { status => 'ok', date => time() };
    $c->render(json => $result);
};

get '/pokemon' => sub ($c) {
    my $result = { name => '', error => 'Please add a pokemon name at the end of the URL' };
    $c->render(json => $result);
};

get '/pokemon/:pokemon_name' => sub ($c) { 
    my $pok = PokemonModule->new;
    my $pokemon_name = lc($c->param("pokemon_name"));
    my $result = $pok->get_shakespearean_pokemon_description($pokemon_name);
    $c->render(json => $result);
};

app->start;
