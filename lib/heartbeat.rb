require 'bunny'
require 'eventmachine'
require 'logger'

class Heartbeat
  
  def initialize
    @logger = Logger.new("log/heartbeat.log")
    @logger.debug "Heartbeat#initialize : Connecting to AMQP server"
    @conn = Bunny.new(:logging => true)
    @conn.start
  end

  def run
    EM.run do
      start_amqp_heartbeat 
    end
  end
  
  private
  
  def start_amqp_heartbeat
    EM.add_periodic_timer(5) do
      @logger.debug "Heartbeat#start_amqp_heartbeat : (periodic timer loop) #{(Time.now.to_f * 1000).to_i}"
      @conn.start unless @conn.connected?
      @conn.exchange("exec-chat-heartbeat", :type => :fanout).publish("#{(Time.now.to_f * 1000).to_i}")
    end
  end
  
end
