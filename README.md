# Baseball Stats

## Server

### Requirements
- MongoDB >= 2.4
- Ruby 2.1.2

### Server setup
Build mongo indexes:

`rake db:mongoid:create_indexes`

Import data:

`rake players:import player_stats:import`.

### Deployment to Heroku

Build mongo indexes:

`heroku run rake db:mongoid:create_indexes`

## Client

### Requirements
- Ruby >= 1.9
- commander gem

### Script usage

First setup environment variables, example:
```
export BASEBALL_STATS_USERNAME=secret_username
export BASEBALL_STATS_PASSWORD=secret_password
export BASEBALL_STATS_SERVER_URI=http://localhost:3000
```

ruby baseball-stats.rb miba --ystart 2009 --yend 2010
ruby baseball-stats.rb tsp --team_id OAK --year 2007
ruby baseball-stats.rb tc --league AL --year 2012