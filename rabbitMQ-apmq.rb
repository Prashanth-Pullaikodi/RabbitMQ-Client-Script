#!/usr/bin/env ruby
require "rubygems"
require "bunny"
require "amqp"
STDOUT.sync = true
# Declaring a durable shared queue
AMQP.start("amqp://admin:password@localhost:5671") do |connection, open_ok|
  channel = AMQP::Channel.new(connection)
  queue   = AMQP::Queue.new(channel, "fos.banking.user", :durable => true)

  connection.close {
    EventMachine.stop { exit }
  }
end
