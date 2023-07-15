module queue_server

import net
import time
import rand

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
		topic: [Topic.new_topic[T]('default')]
	}
	// q.topic[0].channel.start()
	return q
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
	mut topic := q.get_topic(topic_name) or { return error('Topic not found') }
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
		mut handler := new_queue_handler[T](mut connection)
		handler.process_request[string](mut &q.topic)
	}
}
