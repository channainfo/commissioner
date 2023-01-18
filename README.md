# SpreeCmCommissioner

An application platform built on top of Spree commerce for modeling any bussiness applications.

## Installation

1; Add this extension to your Gemfile with this line:

```ruby
gem 'spree_cm_commissioner'
```

2; Install the gem using Bundler

```ruby
bundle install
```

3; Copy & run migrations

```ruby
bundle exec rails g spree_cm_commissioner:install
```

4; Restart your server

If your server was running, restart it so that it can find the assets properly.

## Config

### Rake tasks

```sh
# Seed province data for Cambodia country
rake data:seed_kh_provinces

# Seed option values and type location
rake data:seed_kh_location_option_values

# Reindex Elasticsearch on Vendor model
rake searchkick:reindex CLASS=Spree::Vendor
```

### Google Map

CM commissioner required Google Map key for [map components](app/views/shared/map/_map.html.erb).

```env
# .env
GOOGLE_MAP_KEY = ""
DEFAULT_LATLON = "10.627543,103.522141"
```

<!-- * Describe new config usage above -->
<!-- * Also put in summary at the last section [All environments] below -->

### Elasticsearch

Commissioner required elasticsearch version 8.5.2. We recommend using [evm](https://github.com/duydo/evm) to manage their version.

1, Install EVM (Elasticsearch Version Manager):

```sh
sudo curl -o /usr/local/bin/evm https://raw.githubusercontent.com/duydo/evm/master/evm
sudo chmod +x /usr/local/bin/evm
```

2, Install elasticsearch

```sh
evm install 8.5.2

# To start elasticsearch
evm start

# To stop elasticsearch
evm stop
```

### All environments

Following are required varialbles inside .env

```env
GOOGLE_MAP_KEY = ""
DEFAULT_LATLON = "10.627543,103.522141"
```

## Using Deface DSL (.deface files)

- Make sure the path of override should match the path of view template
- The .deface can be use with :erb, :html, or :text

Example:

```sh
View Template file: app/views/spree/admin/vendors/_form
Override file: app/overrides/spree/admin/vendors/_form/logo.html.erb.deface
```

<https://github.com/spree/deface#using-the-deface-dsl-deface-files>

## Schedule Jobs

- Create a schedule to update vendor min and max price
- Frequently: every 24 hours
- Run time: mid night is preferable
- Command: ``` rake "spree_cm_commissioner:vendor_update_price_range" ```

## Testing

First bundle your dependencies, then run `rake`. `rake` will default to building the dummy app if it does not exist, then it will run specs. The dummy app can be regenerated by using `rake test_app`.

```sh
bundle update
bundle exec rake test_app
```

When testing your applications integration with this extension you may use it's factories.
Simply add this require statement to your spec_helper:

```ruby
require 'spree_cm_commissioner/factories'
```

## Releasing

```sh
bundle exec gem bump -p -t
bundle exec gem release
```

For more options please see [gem-release REAMDE](https://github.com/svenfuchs/gem-release)

## Contributing

If you'd like to contribute, please take a look at the
[instructions](CONTRIBUTING.md) for installing dependencies and crafting a good
pull request.

Copyright (c) 2022 [name of extension creator], released under the New BSD License
