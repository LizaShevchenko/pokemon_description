Pokemon Shakespearean Description
================================

This is a Mojolicious based app which retrieves a Shakespearean description of a requested pokemon.

3rd parties APIs used:
 * https://pokeapi.co
 * https://funtranslations.com/api/shakespeare

## How to Install the Project

### Running locally

First you need docker and docker-compose installed:

https://www.docker.com/community-edition#/download

Then download this repo as a zip archive

Unzip it on your machine in a desired directory, let's call it 'pokemon'

Go to the 'pokemon' directory, then build and run the docker image as following:

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
