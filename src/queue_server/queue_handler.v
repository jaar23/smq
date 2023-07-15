module queue_server

import net { TcpConn }
import io

// GET $Topic
// PUT $Topic:$Data
// CLEAR $Topic
// NEW $Topic

const (
	read_timeout  = 30
	write_timeout = 30
)

pub struct QueueHandler[T] {
pub mut:
	channel chan &TcpConn
}

pub enum Command {
	get
	put
	clear
	new
}

pub struct Request {
pub mut:
	command    Command
	topic_name string
	data       string
}

pub fn new_queue_handler[T](mut conn TcpConn) QueueHandler[T] {
	handler := QueueHandler[T]{
		channel: chan &TcpConn{cap: 1}
	}
	handler.channel <- conn
	return handler
}

pub fn (mut h QueueHandler[T]) response(data []u8) {
}

pub fn (mut h QueueHandler[T]) process_request(mut topics []Topic[T]) {
	mut conn := <-h.channel
	spawn QueueHandler.handle_request[string](mut conn, mut topics)
}

pub fn QueueHandler.handle_request[T](mut conn TcpConn, mut topics []Topic[T]) {
	defer {
		conn.close() or { eprintln('connectiong close() failed: ${err}') }
	}
	conn.set_sock() or { eprintln('cannot set socket operation: ${err}') }
	mut reader := io.new_buffered_reader(reader: conn)
	defer {
		unsafe {
			reader.free()
		}
	}
	for {
		mut line := reader.read_line() or {
			println('${err}')
			return
		}
		if line == '' {
			println('line is empty')
			continue
		}
		mut result := ''.bytes()
		println('receive command: ${line}')
		request := parse_command(line) or {
			result = 'Invalid line of request, valid line will be COMMAND TOPIC <MESSAGE>'.bytes()
			conn.write(result) or { eprintln('cannot response due to ${err}') }
			return
		}
		match request.command {
			.get {
				// get message by topic name from topics
				for i in 0 .. topics.len {
					if request.topic_name == topics[i].name {
						result = topics[i].dequeue_byte()
						println('dequeue: ${result}')
						break
					}
				}
			}
			.put {
				// put message into topic by topic name
				for i in 0 .. topics.len {
					if request.topic_name == topics[i].name {
						topics[i].enqueue(request.data)
						break
					}
				}
			}
			.new {
				topic := Topic.new_topic[T](request.topic_name)
				topics << topic
				result = '${request.topic_name} is added to topics'.bytes()
			}
			.clear {
				for i in 0 .. topics.len {
					if request.topic_name == topics[i].name {
						topics[i].list.destroy()
						break
					}
				}
			}
			else {
				result = 'Invalid command parsed, valid command are GET, PUT, CLEAR, NEW'.bytes()
				conn.write(result) or { eprintln('cannot response due to ${err}') }
			}
		}
		conn.set_read_timeout(queue_server.read_timeout)
		conn.set_write_timeout(queue_server.write_timeout)
		conn.write(result) or { eprintln('cannot handle response: ${err}') }
		break
	}
	return
}

pub fn parse_command(line string) ?Request {
	if line.len < 3 {
		println('invalid line of request')
		return none
	}
	request_arr := line.split(' ')
	topic_name := request_arr[1]
	mut data := ''
	if request_arr.len > 2 {
		for r in request_arr[2..] {
			data += ' ' + r
		}
	}
	if request_arr[0] == 'GET' || request_arr[0] == 'get' {
		return Request{
			command: Command.get
			topic_name: topic_name
			data: data
		}
	} else if request_arr[0] == 'PUT' || request_arr[0] == 'put' {
		return Request{
			command: Command.put
			topic_name: topic_name
			data: data.trim_space()
		}
	} else if request_arr[0] == 'NEW' || request_arr[0] == 'new' {
		return Request{
			command: Command.new
			topic_name: topic_name
			data: ''
		}
	} else if request_arr[0] == 'CLEAR' || request_arr[0] == 'clear' {
		return Request{
			command: Command.clear
			topic_name: topic_name
			data: ''
		}
	}
	return none
}

// pub fn get_topic_message[T](mut topic Topic[T]) []u8 {
// 	return topic.dequeue_byte()
// }
//
// pub fn put_topic_message[T](mut topic Topic[T], data T) {
// 	topic.enqueue(data)
// }
