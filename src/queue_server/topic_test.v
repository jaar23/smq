module topic_test

import queue_server
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

	for i in 2 .. 10 {
		t.enqueue(i.str())
		// dump(t.cursor)
	}
	assert 10 == t.list.size()
}

fn test_topic_dequeue() {
	mut t := queue_server.new_topic[string]('test topic')
	for i in 0 .. 10 {
		t.enqueue(i.str())
	}
	// dump(t.list)
	for i in 0 .. 10 {
		data := t.dequeue()
		// println('data: ${data}')
		assert i.str() == data?
	}
}

fn test_speed_topic_enqueue() {
	mut t := queue_server.new_topic[string]('test topic')
	now := time.now()
	for i in 0 .. 10000 {
		t.enqueue(i.str())
	}
	println('spent ${time.since(now)} to enqueue 10000 message')
}

fn test_speed_topic_dequeue() {
	mut t := queue_server.new_topic[string]('test topic')
	mut now := time.now()
	for i in 0 .. 10000 {
		t.enqueue(i.str())
		// time.sleep(1000)
		// println('left ${t.list.count().str()}')
	}
	println('spent ${time.since(now)} to enqueue 10000 message')
	now = time.now()
	for i in 0 .. 10000 {
		data := t.dequeue()
		// println('dequeued: ${data}')
		// println('left: ${t.list.count().str()}')
	}
	println('spent ${time.since(now)} to deqeue 10000 message')
}

// fn test_parallel_endeq() {
// 	mut t := queue_server.new_topic[string]('test topic')
// 	now := time.now()
// 	t.parallel_endeq(rand.int().str())
// 	println('spent ${time.since(now)} to en-deqeue 1000 message')
// 	println('message left: ${t.list.count().str()}')
// }

fn test_subscribe() {
	mut t := queue_server.new_topic[string]('test topic')
	t.channel.start()
	f := fn (data string) {
		println('success')
		println(data)
	}
	spawn t.channel.send('something')
	spawn t.channel.send('another thing')
	// t.channel.listen() or { println('${err}') }
	t.subscribe(f) or { println('${err}') }
	// t.channel.start()
	spawn t.channel.send('another thing 2')
	t.channel.stop()
}
//
// fn test_subscribe_block() {
// 	mut t := queue_server.new_topic[string]('test topic')
// 	t.channel.start()
// 	f := fn (data string) {
// 		println('success')
// 		println(data)
// 	}
// 	spawn t.channel.send('something')
// 	spawn t.channel.send('another thing')
// 	t.subscribe_block(f) or { println('${err}') }
// 	spawn t.channel.send('another thing 2')
// }
//

fn test_publish() {
	mut t := queue_server.new_topic[string]('test topic')
	t.channel.start()
	f := fn (data string) {
		println('success')
		println(data)
	}
	t.publish('publish something') or { println('${err}')}
	t.publish('publish another thing') or {println(
		'${err}')}
	// t.channel.listen() or { println('${err}') }
	t.subscribe(f) or { println('${err}') }
	// t.channel.start()
	t.publish('publish another thing 2') or {println('${err}')}
	t.channel.stop()
}
