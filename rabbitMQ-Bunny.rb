#!/usr/bin/env ruby
require "rubygems"
require "bunny"

STDOUT.sync = true

conn = Bunny.new("amqp://admin:password@rabbitmq01.com:5671")
conn.start

# open a channel
ch = conn.create_channel
ch.confirm_select

# declare a queue
q  = ch.queue("atest", :durable => true)
q.subscribe(manual_ack: true) do |delivery_info, metadata, payload|
  puts "This is the message: #{payload}"
  # acknowledge the delivery so that RabbitMQ can mark it for deletion
  ch.ack(delivery_info.delivery_tag)
end

sleep 20
# publish a message to the default exchange which then gets routed to this queue
q.publish("Hello, everybody!", persistent: true)

sleep 20
# await confirmations from RabbitMQ, see
# https://www.rabbitmq.com/publishers.html#data-safety for details
ch.wait_for_confirms

# give the above consumer some time consume the delivery and print out the message

sleep 20
puts "Done"

ch.close
# close the connection
conn.close
