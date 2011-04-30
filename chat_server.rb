require 'eventmachine'

class ChatServer
  attr_accessor :host
  attr_accessor :port
  attr_accessor :connections
  
  def initialize(host, port)
    self.host         = host
    self.port         = port
    self.connections  = []
  end
  
  def start
    EM.start_server(host, port, ChatServerConnection) do |conn|
      conn.server = self
      self.connections << conn
    end
    puts "Chat server started on #{host}:#{port}"
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


EventMachine::run {
  ChatServer.new('0.0.0.0', 8081).start
}
