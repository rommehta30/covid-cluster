# README

* Ruby and Rails setup
https://medium.com/@dyanagi/how-to-install-ruby-on-rails-on-clean-install-mac-2a46dd1eee9

* Install the bundler
> gem install bundler

* Install the gems
> bundle install

* Database setup
> rails db:create
> rails db:migrate

* Run the application
> rails s
Above command runs the application at port 30000

* Routes
Hexagon creation form: GET /hexagons/new
View neighbours: GET /hexagons/{NAME OF HEXAGON}
To make hexagon covid free: PATCH /hexagons/{NAME OF HEXAGON}/remove
