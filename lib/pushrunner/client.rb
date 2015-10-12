#require "pushrunner/client/version"
require 'faye/websocket'
require 'eventmachine'


module Pushrunner
  API_VERSION = "1.1"
  @@flags = {}

  def self.set flag
    @@flags[flag]=true
  end

  def self.development?
    return false if @@flags[:development].nil?
    return true
  end

  class Client

    def initialize (url:,ping_interval:10,timeout:5)
      @URL                =   url
      @PING_INTERVAL      =   ping_interval
      @TIMEOUT            =   timeout || ping_interval+10 
      raise  ArgumentError,"The 'timeout:' argument must be greater than 'ping_interval:'" if @PING_INTERVAL > @TIMEOUT

      @methods            =   {}
      @connected_flag     =   false

      @methods["system/pong"]=Proc.new{
        puts "[ #{Time.now.strftime("%Y/%m/%d %H:%M:%S")} Connection Manager:: \t] Pong Received. " if PushRunner.development? 
      }

      connect
      enable_pinger(@PING_INTERVAL)
    end

    public

    def on (method,&block) 
      @methods[method]=block;
    end

    def methods 
      return @methods.keys
    end

    def connected?
      connected_flag
    end

    #register block 
    def onconnect(&block)
      @onconnect_proc = block
    end

    def onclose(&block)
      @onclose_proc = block
    end


    private
    def enable_pinger interval
      return nil unless @watchdog.nil?
      #Set Timer
      @watchdog = EM.add_periodic_timer(interval) do
        ping
        puts "[ #{Time.now.strftime("%Y/%m/%d %H:%M:%S")} WatchDog:: \t] Executed" if PushRunner.development?
      end
    end

    def ping
      if connected? 
       puts "[ #{Time.now.strftime("%Y/%m/%d %H:%M:%S")} Websocket:: \t] Send ping." if PushRunner.development?
       @ws.send Message.new(method:"system/ping").to_json
      end
    end

    def pong
      # refresh timeout timer
      @last_pong_time = Time.now
      @last_pong_timer.cancel if @last_pong_timer.instance_of?(EventMachine::Timer) #cancel old timer
      @last_pong_timer = EventMachine::Timer.new(@TIMEOUT) { 
        #disconnect when no longer receiving pong packet.
        puts "[ #{Time.now.strftime("%Y/%m/%d %H:%M:%S")} Connection Manager:: \t] No Longer pong packet received. " if PushRunner.development? 
        disconnected
      }
    end

    #called when connected
    def connected
      instance_eval(&@onconnect_proc) #if @onconnect_proc.instance_of?(Proc) && @connected_flag == false
      @connected_flag = true
    end

    #called when disconnected
    def disconnected
      instance_eval(&@onclose_proc) if @onclose_proc.instance_of?(Proc) && @connected_flag == true
      @connected_flag = false
      puts "[ #{Time.now.strftime("%Y/%m/%d %H:%M:%S")} Websocket:: \t] Disconnected. " if PushRunner.development? 
      sleep 5
      connect
    end

    def connected?
      @connected_flag
    end


    def connect
      puts "[ #{Time.now.strftime("%Y/%m/%d %H:%M:%S")} Websocket:: \t] Connecting to #{@URL}." if PushRunner.development? 
      @ws = Faye::WebSocket::Client.new(@URL, nil,  ping: 10)

      @ws.on :open do |event|
        puts "[ #{Time.now.strftime("%Y/%m/%d %H:%M:%S")} Websocket:: \t] Connected." if PushRunner.development?
        connected
      end 

      @ws.on :message do |event|
        # here is the entry point for data coming from the server.
        begin
          pong
          msg = JSON.parse(event.data,:symbolize_names => true)
          method = msg[:status][:method]
          body = msg[:body]
          block = @methods[method]
          self.instance_exec(body,&block)   #execute block
        rescue => e
          unless method.start_with?("system") then
           puts "[ #{Time.now.strftime("%Y/%m/%d %H:%M:%S")} Parser:: \t] Error Occured in parse e:#{e}."  if PushRunner.development?
          end
        end

      end 

      @ws.on :close do |event|
        # connection has been closed callback.
        puts "[ #{Time.now.strftime("%Y/%m/%d %H:%M:%S")} Websocket:: \t] Closed. #{event.code} #{event.reason}" if PushRunner.development?
        disconnected
      end
    end

  end

  class Message < Hash
    def initialize(options={})
      super()
      templete = {
        :api_version => API_VERSION,
        :status=>{
          :created_at => Time.now.to_i,
          :created_at_humanity=>Time.now,
          :method => options[:method] || nil
        },
        self[:body] => options[:body] || nil
      }

      self.merge!(templete)
    end

    def body val
      self[:body]=val unless val.nil?
    end

    def method val
      self[:method]=val unless val.nil?
    end

  end

end
