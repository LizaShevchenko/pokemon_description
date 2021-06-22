package PokemonModule;
use HTTP::Request;
use JSON::XS;
use LWP::Protocol::https;
use LWP::UserAgent;
use Readonly;
use Try::Tiny;
use Moo;

Readonly my $POKEAPI_URL => "https://pokeapi.co/api/v2/pokemon-species/";
Readonly my $FUNTRANSLATIONS_URL => "https://api.funtranslations.com/translate/shakespeare.json?text=";
Readonly my %ERROR => (pokemon_doesnt_exist => "This pokemon doesn't exist! This is a full list of Pokemons: https://www.pokemon.com/us/pokedex/",
                        pokemon_description_unavailable => "Pokemon description is unavailable at the moment.",
                        translation_unavailable => "Can't get the Pokemon description at the moment. Please try in "
                        );

sub get_shakespearean_pokemon_description {
    my $self = shift;
    my $pokemon_name = shift;

    my $output = { name => $pokemon_name};

    my ($pokeapi_error, $pokemon_description) = $self->_get_pokemon_details_by_name($pokemon_name);
    if ($pokeapi_error) {
        $output->{'error'} = $pokeapi_error;
        return $output;
    }

    my ($translation_error, $translation) = $self->_translate_into_shakespearean_text($pokemon_description);
    if ($translation_error) {
        $output->{'error'} = $translation_error;
        return $output;
    }

    $output->{'description'} = $translation;

    return $output;
}

sub _build_user_agent {
    my $self = shift;
    my $request = shift;

    my $ua = LWP::UserAgent->new;
    $ua->agent('Mozilla/5.0');
    my $response = $ua->request($request);

    return $response;
}

sub _parse_json {
    my $self = shift;
    my $content = shift;

    my $response;
    try {
        $response = JSON::XS::decode_json($content);
    } catch {
        warn "Returned content is not JSON. $_"
    };

    return $response;
}

sub _get_pokemon_details_by_name {
    my $self = shift;
    my $pokemon_name = shift;

    my $request = HTTP::Request->new(GET => $POKEAPI_URL . $pokemon_name );
    my $response = $self->_build_user_agent($request);

    if (!$response->is_success) {
        warn "Request to pokeapi.co was unsuccessful.";
        return ($ERROR{pokemon_doesnt_exist},0);
    }

    my $json_decoded_response = $self->_parse_json($response->decoded_content());

    #if the original response was not JSON this check will be skipped
    if ($json_decoded_response->{"flavor_text_entries"}) {
        my $i = 0;
        while (my $flavor_text_entries = $json_decoded_response->{"flavor_text_entries"}) {
            #looking for the first English entry within flavor_text_entries
            if ($flavor_text_entries->[$i]->{'language'}->{'name'} eq 'en') {
                my $pokemon_description = $flavor_text_entries->[$i]->{"flavor_text"}; 

                #cleaning the flavor_text by removing excessive new lines and \f
                $pokemon_description =~ s/(\n|\f)/ /g;
                return (0,$pokemon_description);
            }
            $i++;
        }
    }
    
    warn "Request to pokeapi.co was successful but expected JSON was not received.";
    return ($ERROR{pokemon_description_unavailable},0);
}

sub _translate_into_shakespearean_text {
    my $self = shift;
    my $pokemon_description = shift;

    my $request = HTTP::Request->new(GET => $FUNTRANSLATIONS_URL . $pokemon_description);
    my $response = $self->_build_user_agent($request);

    #cheking whether the response was unsuccessul but excluding error code 429 as it is checked below
    if (!$response->is_success && $response->code != 429) {
        warn "Request to api.funtranslations.com was unsuccessful.";
        return ($ERROR{pokemon_description_unavailable},0);
    }

    my $json_decoded_response = $self->_parse_json($response->decoded_content());

    #this error message retured on error code 429, hence this code is excluded from the previous check
    if ($json_decoded_response->{"error"}->{"message"}) {
        my $wait_time = $json_decoded_response->{"error"}->{"message"};

        #grabbing the wait time until the next successful request in order to use in the error message
        $wait_time =~ s/Too Many Requests: Rate limit of 5 requests per hour exceeded. Please wait for //;
        
        warn "Request to api.funtranslations.com was unsuccessful: ". $json_decoded_response->{"error"}->{"message"};
        return ($ERROR{translation_unavailable} . $wait_time,0);
    }

    #if the original response was not JSON this check will be skipped
    if ($json_decoded_response->{"contents"}->{"translated"}) {
        my $translated_text = $json_decoded_response->{"contents"}->{"translated"};

        return (0,$translated_text);
    }

    warn "Request to api.funtranslations.com was successful but expected JSON was not received.";
    return ($ERROR{pokemon_description_unavailable},0);
}

1;