# Pushrunner::Client

The Client of Simple Bidirectinal Server-Client Push Message Protocol.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pushrunner-client', github: 'aquahika/pushrunner-client'
```

You should require this gem like;

```ruby
require 'pushrunner/client'
```


## Usage

```ruby
require 'pushrunner/client'

EM.run do
 #s PushRunner::set :development

  con = PushRunner::Client.new(url:" <==== YOUR PUSHRUNNER SERVER ADDRESS ====> ",ping_interval:5,timeout:8)

  con.on 'light/on' do
    puts "Turning on light"
  end

  con.on 'light/off' do
    puts "Turning off light"
  end  

  con.on 'thermostat/set' do |value|
    puts "setting thermostat to #{value} degree"
  end


  con.onclose do
    puts "Connection has been closed!"
  end

  con.onconnect do
    puts "Connected to Server!"
  end

end

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake false` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aquahika/pushrunner-client.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

