require 'eventmachine'

class ChatClient < EM::Connection
  attr_reader :queue, :queue_handler

  def initialize
    @queue          = EM::Queue.new
    @queue_handler  = ->(msg) { process!(msg) }
    pop!
  end

  def pop!
    @queue.pop(&@queue_handler)
  end

  def process!(msg)
    send_data(msg)
    pop!
  end

  def post_init
  end

  def receive_data(data)
    puts data
  end
  
  def unbind
    puts "connection closed"
    EM.stop
  end
  
  def self.run(host, port)
    EM.run {
      EM.connect(host, port, ChatClient) do |client|
        EM.open_keyboard(KeyboardHandler, client.queue)
      end
      puts "Chat client connecting to #{host}:#{port}"
    }
  end
end

class KeyboardHandler < EM::Connection
  include EM::Protocols::LineText2

  attr_reader :queue

  def initialize(queue)
    @queue = queue
  end

  def receive_line(data)
    @queue.push(data)
  end
end

ChatClient.run('127.0.0.1', 8081)
