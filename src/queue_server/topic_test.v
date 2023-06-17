module topic_test

import queue_server {Topic}
import time
import rand

fn test_new_topic() {
  mut t := queue_server.new_topic[string]('test topic')
}

fn test_topic_enqueue() {
  mut t := queue_server.new_topic[string]('test topic')
	t.enqueue('something')
	t.enqueue('another thing')
	assert 2 == t.list.size()

	for i in 2..10 {
		t.enqueue(i.str())
		// dump(t.cursor)
	}
	assert 10 == t.list.size()
}

fn test_topic_dequeue() {
  mut t := queue_server.new_topic[int]('test topic')
	for i in 0..10 {
		t.enqueue(i)
	}
	// dump(t.list)
	for i in 0..10 {
		data := t.dequeue()
		// println('data: ${data}')
		assert i == data?
	}
}

fn test_speed_topic_enqueue() {
	mut t := queue_server.new_topic[int]('test topic')
	now := time.now()
	for i in 0..10000 {
		t.enqueue(i)
	}
	println('spent ${time.since(now)} to enqueue 10000 message')
}

fn test_speed_topic_dequeue() {
	mut t := queue_server.new_topic[int]('test topic')
	mut now := time.now()
	for i in 0..10000 {
		t.enqueue(i)
		//time.sleep(1000)
		//println('left ${t.list.count().str()}')
	}
	println('spent ${time.since(now)} to enqueue 10000 message')
	now = time.now()
	for i in 0..10000 {
		data := t.dequeue()
		// println('dequeued: ${data}')
		//println('left: ${t.list.count().str()}')
	}
	println('spent ${time.since(now)} to deqeue 10000 message')
}

fn test_parallel_endeq() {
	mut t := queue_server.new_topic[string]('test topic')
	now := time.now()
	t.parallel_endeq(rand.int().str())
	println('spent ${time.since(now)} to en-deqeue 1000 message')
	println('message left: ${t.list.count().str()}')
}

