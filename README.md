# Baseball Stats

## Server requirements
- MongoDB >= 2.4
- Ruby 2.1.2

## Server setup
Build mongo indexes:

`rake db:mongoid:create_indexes`

Import data:

`rake players:import player_stats:import`.

## Deployment to Heroku

Build mongo indexes:

`heroku run rake db:mongoid:create_indexes`

## Client script usage