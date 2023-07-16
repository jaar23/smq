# smq

queue system implemented in v, inserting 10 million of record in 1 second.

### Getting Started

`smq` is a simple queue system that allow user get, put data into queue easily.

You can define new queue's topic and clean up all the data inside the queue.

Run this command to start `smq`
```
./smq -c config.toml
```

In order to interact to `smq`, you will need a client. Please proceed to https://github.com/jaar23/smq_client for the client library.

### Performance

Approximately:

read per second: 6747 reqests per second

write per second: 5555 requests per second
