module queue_server

import net { TcpConn }
import io
import os

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
	count
}

pub struct Request {
pub mut:
	command    Command
	topic_name string
	data       string
}

pub enum ResponseStatus {
	ok
	err
}

pub struct Response {
	status  ResponseStatus
	code    int
	message string
	data    string
}

pub fn new_queue_handler[T](mut conn TcpConn) QueueHandler[T] {
	handler := QueueHandler[T]{
		channel: chan &TcpConn{cap: 1}
	}
	handler.channel <- conn
	return handler
}

pub fn (h QueueHandler[T]) process_request(mut topics []Topic[T]) {
	mut conn := <-h.channel
	spawn handle_request[string](mut conn, mut topics)
}

pub fn Response.new(status ResponseStatus, code int, message string, data string) Response {
	return Response{
		status: status
		code: code
		message: message
		data: data
	}
}

pub fn (resp Response) to_byte() []u8 {
	mut result := 'STATUS ${resp.status}\r\n'
	result += 'CODE ${resp.code.str()}\r\n'
	result += 'MESSAGE ${resp.message}\r\n'
	result += '${resp.data}\r\n'
	if log_level := os.getenv_opt('SMQ_LOG_LEVEL') {
		if log_level == 'DEBUG' || log_level == 'debug' {
			println(result)
		}
	}
	return result.bytes()
}

pub fn handle_request[T](mut conn TcpConn, mut topics []Topic[T]) {
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
		mut result := ''
		mut code := 0
		mut status := ResponseStatus.ok
		mut message := ''
		// println('receive command: ${line}')
		request := parse_command(line) or {
			message = 'Invalid line of request, valid line will be COMMAND TOPIC <MESSAGE>'
			resp := Response.new(ResponseStatus.err, 2, message, result)
			conn.write(resp.to_byte()) or { eprintln('cannot response due to ${err}') }
			return
		}
		match request.command {
			.get {
				// get message by topic name from topics
				for i in 0 .. topics.len {
					if request.topic_name == topics[i].name {
						result = topics[i].dequeue() or {
							code = 3
							message = 'Data not found'
							resp := Response.new(status, code, message, result)
							conn.set_read_timeout(queue_server.read_timeout)
							conn.set_write_timeout(queue_server.write_timeout)
							conn.write(resp.to_byte()) or {
								eprintln('cannot handle response: ${err}')
							}
							return
						}
						// println('dequeue: ${result}')
						break
					}
				}
			}
			.put {
				// put message into topic by topic name
				for i in 0 .. topics.len {
					if request.topic_name == topics[i].name {
						topics[i].enqueue[T](request.data)
						break
					}
				}
			}
			.new {
				mut found := false
				for i in 0 .. topics.len {
					if request.topic_name == topics[i].name {
						found = true
						break
					}
				}
				if found {
					status = ResponseStatus.err
					code = 4
					message = '${request.topic_name} already existed'
				} else {
					topic := Topic.new[T](request.topic_name)
					topics << topic
					message = '${request.topic_name} is added to topics'
				}
			}
			.clear {
				mut is_reset := false
				for i in 0 .. topics.len {
					if request.topic_name == topics[i].name {
						topics[i].list.destroy()
						message = '${request.topic_name} has been reset'
						is_reset = true
						break
					}
				}
				if !is_reset {
					code = 5
					status = ResponseStatus.err
					message = '${request.topic_name} fail to reset, it is probably not found'
				}
			}
			.count {
				mut not_found := true
				for i in 0 .. topics.len {
					if request.topic_name == topics[i].name {
						topic_size := topics[i].list.size
						message = '${request.topic_name} has ${topic_size.str()} in queue'
						not_found = false
						result = topic_size.str()
						break
					}
				}
				if not_found {
					code = 6
					status = ResponseStatus.err
					message = 'Fail to cound${request.topic_name}, it is not found'
				}
			}
			// else {
			// 	result = 'Invalid command parsed, valid command are GET, PUT, CLEAR, NEW'.bytes()
			// 	conn.write(result) or { eprintln('cannot response due to ${err}') }
			// }
		}
		resp := Response.new(status, code, message, result)
		conn.set_read_timeout(queue_server.read_timeout)
		conn.set_write_timeout(queue_server.write_timeout)
		conn.write(resp.to_byte()) or { eprintln('cannot handle response: ${err}') }
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
	} else if request_arr[0] == 'COUNT' || request_arr[0] == 'count' {
		return Request{
			command: Command.count
			topic_name: topic_name
			data: ''
		}
	}
	return none
}
