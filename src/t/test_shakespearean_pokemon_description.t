use lib '../lib';
use HTTP::Headers;
use HTTP::Message;
use HTTP::Response;
use Mojo::Base -strict;
use Test::MockModule;
use Test::Mojo;
use Test::More;

my $module = Test::MockModule->new('PokemonModule');
my $po=PokemonModule->new;

subtest 'Use dependencies' => sub {
    use_ok('HTTP::Headers');
    use_ok('HTTP::Message');
    use_ok('HTTP::Request');
    use_ok('HTTP::Response');
    use_ok('JSON::XS');
    use_ok('LWP::Protocol::https');
    use_ok('LWP::UserAgent');
    use_ok('Mojolicious::Lite');
    use_ok('Moo');
    use_ok('PokemonModule');
    use_ok('Readonly');
    use_ok('Test::MockModule');
    use_ok('Test::Most');
    use_ok('Try::Tiny');
};

subtest 'Test description retrieval' => sub {

    #Testing when pokeapi returns 503 Service Unavailable
    $module->mock('_build_user_agent', sub {
        my $response = HTTP::Response->new(503);
        return $response;
    });
    my ($error,$description)=$po->_get_pokemon_details_by_name('pikachu');
    is($error,"This pokemon doesn't exist! This is a full list of Pokemons: https://www.pokemon.com/us/pokedex/","Returned error is correct");
    is($description,0,"Description is empty which is correct");

    #Testing when pokeapi returns 200 with expected JSON
    $module->mock('_build_user_agent', sub {
        my $header = HTTP::Headers->new;
        my $msg = HTTP::Message->new;
        my $response = HTTP::Response->new(200,$msg,$header,'{"egg_groups":[{"name":"ground","url":"https://pokeapi.co/api/v2/egg-group/5/"},{"name":"fairy","url":"https://pokeapi.co/api/v2/egg-group/6/"}],"evolution_chain":{"url":"https://pokeapi.co/api/v2/evolution-chain/10/"},"evolves_from_species":{"name":"pichu","url":"https://pokeapi.co/api/v2/pokemon-species/172/"},"flavor_text_entries":[{"flavor_text":"...","language":{"name":"zh-Hant","url":"https://pokeapi.co/api/v2/language/4/"},"version":{"name":"sun","url":"https://pokeapi.co/api/v2/version/27/"}},{"flavor_text":"When several of\nthese POKeMON\ngather, their\felectricity could\nbuild and cause\nlightning storms.","language":{"name":"en","url":"https://pokeapi.co/api/v2/language/9/"},"version":{"name":"red","url":"https://pokeapi.co/api/v2/version/1/"}}]}');
        return $response;
    });
    ($error,$description)=$po->_get_pokemon_details_by_name('pikachu');
    is($error,0,"Returned success is correct");
    is($description,"When several of these POKeMON gather, their electricity could build and cause lightning storms.","Description is correct");

    #Testing when pokeapi returns 200 with unexpected JSON
    $module->mock('_build_user_agent', sub {
        my $header = HTTP::Headers->new;
        my $msg = HTTP::Message->new;
        my $response = HTTP::Response->new(200,$msg,$header,'{"egg_groups":[{"name":"ground","url":"https://pokeapi.co/api/v2/egg-group/5/"},{"name":"fairy","url":"https://pokeapi.co/api/v2/egg-group/6/"}],"evolution_chain":{"url":"https://pokeapi.co/api/v2/evolution-chain/10/"},"evolves_from_species":{"name":"pichu","url":"https://pokeapi.co/api/v2/pokemon-species/172/"}}');
        return $response;
    });
    ($error,$description)=$po->_get_pokemon_details_by_name('pikachu');
    is($error,"Pokemon description is unavailable at the moment.",0);
    is($description,0,"Description is empty which is correct");

};

subtest 'Test translation retrieval' => sub {
    
    #Testing when funtranslations API returns 503 Service Unavailable
    $module->mock('_build_user_agent', sub {
        my $response = HTTP::Response->new(503);
        return $response;
    });
    my ($error,$description)=$po->_translate_into_shakespearean_text("When several of these POKeMON gather, their electricity could build and cause lightning storms.");
    is($error,"Pokemon description is unavailable at the moment.","Returned error is correct");
    is($description,0,"Description is empty which is correct");

    #Testing when funtranslations API returns 429 code with an error message
    $module->mock('_build_user_agent', sub {
        my $header = HTTP::Headers->new;
        my $msg = HTTP::Message->new;
        my $response = HTTP::Response->new(429,$msg,$header,'{"error":{"code":429,"message":"Too Many Requests: Rate limit of 5 requests per hour exceeded. Please wait for 59 minutes and 59 seconds."}}');
        return $response;
    });
    ($error,$description)=$po->_translate_into_shakespearean_text("When several of these POKeMON gather, their electricity could build and cause lightning storms.");
    is($error,"Can't get the Pokemon description at the moment. Please try in 59 minutes and 59 seconds.","Returned error is correct");
    is($description,0,"Description is empty which is correct");

    #Testing when funtranslations API returns 429 code with no error message
    $module->mock('_build_user_agent', sub {
        my $header = HTTP::Headers->new;
        my $msg = HTTP::Message->new;
        my $response = HTTP::Response->new(429,$msg,$header,'{"error":{"code":429}}');
        return $response;
    });
    ($error,$description)=$po->_translate_into_shakespearean_text("When several of these POKeMON gather, their electricity could build and cause lightning storms.");
    is($error,"Pokemon description is unavailable at the moment.","Returned error is correct");
    is($description,0,"Description is empty which is correct");

    #Testing when funtranslations API returns 200 with the expected JSON
    $module->mock('_build_user_agent', sub {
        my $header = HTTP::Headers->new;
        my $msg = HTTP::Message->new;
        my $response = HTTP::Response->new(200,$msg,$header,'{"contents":{"translated":"this is shakespearean description"}}');
        return $response;
    });
    ($error,$description)=$po->_translate_into_shakespearean_text("When several of these POKeMON gather, their electricity could build and cause lightning storms.");
    is($error,0,"Returned success is correct");
    is($description,"this is shakespearean description","Description is correct");
};

done_testing();
1;