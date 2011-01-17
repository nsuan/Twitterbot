require 'rubygems'
require 'xmpp4r'
require 'thread'
include Jabber

class Twitterbot
 # attr_accessor :com
  def initialize(server, name, password)
    @com = Component::new(name, server)
    @com.connect
    @com.auth(password)
    @msg_queue = Queue.new
    
    @com.add_presence_callback do |pres|
    	 puts pres.type.to_s
    	 case pres.type.to_s
    		  when 'probe': send_online(pres)
    		  when 'subscribe': send_subscribed(pres)
    		  when 'unsubscribe': send_unsubscribed(pres)
    	 end
    end
    @com.add_message_callback do |msg|
      #puts msg
      @msg_queue.push msg
    end
    
    @reader = Thread.new do
        loop do
          message = @msg_queue.pop
          do_message(message)
        end
    end
  end
  def do_message(message) 
    puts make_jid(message.from.to_s) + ": "  + message.body
  end
  def send_subscribed(pres)
    puts "Authorizing " + pres.from.to_s + " for "  + pres.to.to_s
    p = Jabber::Presence.new.set_type(:chat).set_status('I am a twitter robot')
    p.set_from(pres.to)
    p.set_type(:probe)
    @com.send(p)
  	p = Presence.new.set_type(:subscribed)
  	p.set_from(pres.to)
  	p.set_to(pres.from)
  	@com.send(p)
  	#@com.send(Presence.new.set_type(:subscribe).set_from("tweet.1e400.net").set_to(from))
  end
  def send_unsubscribed(pres)
    puts "Deuthorizing " + pres.from.to_s + " for "  + pres.to.to_s
  	p = Presence.new.set_type(:unsubscribed)
  	p.set_from(pres.to)
  	p.set_to(pres.from)
  	@com.send(p)
  end
  def make_jid(jid)
     Jabber::JID.new(message.from.to_s).strip().to_s
  end
  def send_online(pres)
    puts "I've been probed!"
  	p = Jabber::Presence.new.set_show(:chat).set_status('I am a twitter robot')
  	p.from = pres.to
  	p.to = make_jid(pres.from.to_s)
  	@com.send(p)
  end
end

