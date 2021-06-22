Pokemon Shakespearean Description
================================

This is a Mojolicious based app which retrieves a Shakespearean description of a requested pokemon.

3rd party APIs used:
 * https://pokeapi.co
 * https://funtranslations.com/api/shakespeare

## How to Install the Project

### Running locally

First you need to have Docker installed:

https://www.docker.com/products/docker-desktop

Clone the repo

    git clone git@github.com:LizaShevchenko/pokemon_description.git

Go to the directory pokemon_description you just cloned, then build and run the docker image as following (make sure Docker app is running):

    docker build -t pokemon .
    docker run -p 8080:8080 pokemon

Start the app by running this command

    ./pokemon.pl daemon -m production -l http://*:8080

Now the app is running on http://127.0.0.1:8080

## How to Use the Project

After building and running the image, go to the URL below in a browser specifying a pokemon name at the end of the URL. Let's try pikachu:

http://127.0.0.1:8080/pokemon/pikachu

If the pokemon you specified is an existing pokemon you will get a JSON response back with the Shakespearean description of it.

Example: For this request http://127.0.0.1:8080/pokemon/pikachu you would see this response:

    {"description":"At which hour several of these pokémon gather,  their electricity couldst buildeth and cause lightning storms.","name":"pikachu"}


## Tests

While running the Docker image, run the following command from the main directory (pokemon_description)

    prove t

Expected Test output
    t/test_shakespearean_pokemon_description.t .. 1/? Request to pokeapi.co was unsuccessful. at ../lib/PokemonModule.pm line 73.
    Request to pokeapi.co was successful but expected JSON was not received. at ../lib/PokemonModule.pm line 95.
    Request to api.funtranslations.com was unsuccessful. at ../lib/PokemonModule.pm line 108.
    Request to api.funtranslations.com was unsuccessful: Too Many Requests: Rate limit of 5 requests per hour exceeded. Please wait for 59 minutes and 59 seconds. at ../lib/PokemonModule.pm line 121.
    Request to api.funtranslations.com was successful but expected JSON was not received. at ../lib/PokemonModule.pm line 132.
    t/test_shakespearean_pokemon_description.t .. ok   
    All tests successful.
    Files=1, Tests=3,  0 wallclock secs ( 0.02 usr  0.01 sys +  0.33 cusr  0.04 csys =  0.40 CPU)
    Result: PASS
