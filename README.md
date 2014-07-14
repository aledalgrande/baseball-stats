# Baseball Stats

## Server

### Requirements
- MongoDB >= 2.4
- Ruby 2.1.2

### Server local setup
Start mongo:

`mongod`

Build mongo indexes:

`rake db:mongoid:create_indexes`

Import data:

`rake players:import player_stats:import`

Install gems:

`bundle install`

Start server with:

`rails s`

### Deployment to Heroku

Deploy (add mongolab add-on):

`git push heroku master`

Build mongo indexes:

`heroku run rake db:mongoid:create_indexes`

Set up environment variables:

`heroku config:set BASEBALL_STATS_USERNAME=secret_username BASEBALL_STATS_PASSWORD=secret_password`

## Client

### Requirements
- Ruby >= 1.9
- commander gem

### Script usage

The script is included in the root folder of the project.

First setup environment variables, example:
```
export BASEBALL_STATS_USERNAME=secret_username
export BASEBALL_STATS_PASSWORD=secret_password
export BASEBALL_STATS_SERVER_URI=http://localhost:3000
```

The commands follow:

* improved batting average: `ruby baseball-stats.rb miba --ystart 2009 --yend 2010`
* slugging percentages: `ruby baseball-stats.rb tsp --team_id OAK --year 2007`
* triple crown: `ruby baseball-stats.rb tc --league AL --year 2012`