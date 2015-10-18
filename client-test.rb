require 'pushrunner/client'



EM.run do
 PushRunner::set :development

  con = PushRunner::Client.new(
    url:"ws://api.gohan.xyz/hometalk/stream",
    ping_interval:5,
    timeout:8
    )

  #
  #  Airconditionar 
  #

  con.on 'ac/on' do
    ac.on!
    puts "Turning on the airconditioner"
  end

  con.on 'ac/off' do
    ac.off!
    puts "Turning off the airconditioner"
  end  

  con.on 'ac/temp/set' do |body|
    return if !(body.nil?) and !(body.empty?) and (body.instance_of?(String) or body.instance_of?(Integer))
    temp = body.to_i;
    ac.set_temperature temp
    puts "Setting AC temp to #{temp} degree."
  end


  #
  #  light
  #

  con.on 'light/on' do
    puts "Turning on light"
    light.on!
  end

  con.on 'light/off' do
    puts "Turning off light"
    light.off!
  end


  #
  #  Door Lock
  #

  con.on 'door/lock' do
    puts "lock the door"
    door_lock.close!
  end  

  con.on 'door/unlock' do
    door_lock.open!
  end


  #
  #  System
  #

  con.onclose do
    puts "サーバーにつながりません"
  end

  con.onconnect do
    puts "サーバーにつながりました"
  end

end