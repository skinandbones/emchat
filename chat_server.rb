require 'eventmachine'

class ChatServer
  attr_reader :connections
  
  def initialize()
    @connections  = []
  end
  
  def self.run(host, port)
    server = self.new
    EventMachine::run {
      EM.start_server(host, port, ChatServerConnection) do |conn|
        conn.server = server
        server.connections << conn
      end
      puts "Chat server started on #{host}:#{port}"
    }
  end
end

class ChatServerConnection < EM::Connection
  attr_accessor :server
  
  def post_init
    puts "-- CONNECT"
  end

  def receive_data(data)
    broadcast(">> #{data.chomp}")
  end
  
  def broadcast(data)
    puts data
    server.connections.each do |conn|
      conn.send_data(data) unless conn == self
    end
  end
  
  def unbind
    server.connections.delete(self)
    puts "-- DISCONNECT"
  end
end

ChatServer.run('0.0.0.0', 8081)
