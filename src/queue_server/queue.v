module queue_server

import net
// import time
// import rand
import toml
import term

[heap]
pub struct Queue[T] {
pub mut:
	topic []Topic[T]
	addr  string
	port  int
	state QueueState
}

pub enum QueueState {
	start
	stop
	pause
	resume
}

pub struct QueueError {
	code          int
	error_message string
}

pub fn (mut q Queue[T]) start() {
}

pub fn (mut q Queue[T]) stop() {
}

pub fn (mut q Queue[T]) pause() {
}

pub fn (mut q Queue[T]) resume() {
}

pub fn init_queue[T]() Queue[T] {
	mut q := Queue[T]{
		addr: '127.0.0.1'
		port: 6789
		state: QueueState.start
		topic: [Topic.new[T]('default')]
	}
	println(term.bg_blue('smq configuration'))
	println('address        : 127.0.0.1')
	println('port           : 6789')
	println('default topic  : default')
	// q.topic[0].channel.start()
	return q
}

pub fn init_queue_with_config[T](path string) !Queue[T] {
	config := read_config(path) or { panic('Unable to read config file: ${err}') }
	addr := config.value('queue.addr').string()
	port := config.value('queue.port').int()
	default_topic := config.value('queue.default_topic').string().trim_space()
	println(term.bold('smq configuration'))
	println('address            : ${addr}')
	println('port               : ${port}')
	println('default topic      : ${default_topic}')
	mut q := Queue[T]{
		addr: addr
		port: port
		topic: [Topic.new[T](default_topic)]
		state: QueueState.start
	}

	defined_topics := config.value('queue.topics').array()
	for n in 0 .. defined_topics.len {
		name := defined_topics[n].value('name').string().trim_space()
		mut topic := Topic.new[T](name)
		q.new_topic(mut topic)
		println('user defined topic : ${name}')
	}

	return q
}

pub fn read_config(path string) !toml.Doc {
	return toml.parse_file(path)
}

pub fn (mut q Queue[T]) new_topic(mut topic Topic[T]) {
	q.topic << topic
}

pub fn (q Queue[T]) get_topic(topic_name string) ?&Topic[T] {
	for i in 0 .. q.topic.len {
		if topic_name == q.topic[i].name {
			return &q.topic[i]
		}
	}
	return none
}

pub fn (mut q Queue[T]) set_addr(addr string) {
	q.addr = addr
}

pub fn (mut q Queue[T]) get_addr() string {
	return q.addr
}

pub fn (mut q Queue[T]) set_port(port int) {
	q.port = port
}

pub fn (q Queue[T]) get_port() int {
	return q.port
}

pub fn (mut q Queue[T]) put(topic_name string, data T) ! {
	mut topic := q.get_topic(topic_name) or { return error('Topic not found') }
	topic.enqueue(data)
}

pub fn (mut q Queue[T]) get(topic_name string) ?T {
	mut topic := q.get_topic(topic_name) or { return none }
	return topic.dequeue()
}

pub fn (mut q Queue[T]) listen() ? {
	// listen to port and read byte in
	mut network := net.listen_tcp(net.AddrFamily.ip, '${q.addr}:${q.port}') or {
		ecode := err.code()
		panic('failed to listen ${ecode}: ${err}')
	}

	for {
		mut connection := network.accept_only() or {
			if err.code() == net.err_timed_out_code {
				// just skip network timeouts, they are normal
				continue
			}
			eprintln('accept() failed, reason: ${err}; skipping')
			continue
		}
		handler := new_queue_handler[T](mut connection)
		handler.process_request[string](mut &q.topic)
	}
}
