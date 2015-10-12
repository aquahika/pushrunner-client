require 'pushrunner/client'

EM.run do
 # PushRunner::set :development

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