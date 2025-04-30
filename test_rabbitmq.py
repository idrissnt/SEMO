import pika

# Try to establish a connection to RabbitMQ
try:
    connection = pika.BlockingConnection(
        pika.ConnectionParameters(host='localhost')
    )
    channel = connection.channel()
    print("Successfully connected to RabbitMQ!")
    
    # Create a test queue
    channel.queue_declare(queue='test_queue')
    print("Successfully created a test queue!")
    
    # Close the connection
    connection.close()
    print("Connection closed properly.")
except Exception as e:
    print(f"Failed to connect to RabbitMQ: {e}")
