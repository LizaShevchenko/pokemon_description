Pokemon Shakespearean Description
================================

This is a Mojolicious based app which retrieves a Shakespearean description of a requested pokemon.

3rd parties APIs used:
 * https://pokeapi.co
 * https://funtranslations.com/api/shakespeare

## How to Install the Project

### Running locally

First you need docker installed:

https://www.docker.com/products/docker-desktop

Clone the repo

    git clone git@github.com:LizaShevchenko/pokemon_description.git

Go to the directory pokemon_description you just cloned, then build and run the docker image as following (make sure Docker app is running):

    docker build -t pokemon .
    docker run -p 8080:8080 pokemon

Now the app is running on 127.0.0.1:8080

## How to Use the Project

After building and running the image, go to the URL below in a browser specifying a pokemon name at the end of the URL. Let's try pikachu:

127.0.0.1:8080/pokemon/pikachu

If the pokemon you specified is an existing pokemon you will get a JSON response back with the Shakespearean description of it.

Example: For this request 127.0.0.1:8080/pokemon/pikachu you would see this response:

    {"description":"At which hour several of these pokémon gather,  their electricity couldst buildeth and cause lightning storms.","name":"pikachu"}


## Tests
