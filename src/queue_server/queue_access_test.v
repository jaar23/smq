module queue_access_test

import time
import net
import io
// import queue_server

// fn test_queue_listen() {
// 	// mut t := queue_server.new_topic[string]
// 	// ('test topic')
// 	// mut q := Queue[string]{
// 	// 	port: 6789
// 	// }
// 	// q.new_topic(mut t)
// 	mut queue := queue_server.init_queue[string]()
// 	print_msg := fn (message string) {
// 		println(message)
// 	}
// 	queue.topic[0].subscribe(print_msg) or { println('${err}') }
// 	queue.listen()
// }

fn test_queue_write() ! {
	for n in 0 .. 100 {
		mut client := net.dial_tcp('127.0.0.1:6789') or { panic('${err}') }
		client.set_read_timeout(30 * time.second)
		client.set_write_timeout(30 * time.second)
		// read_resp := fn (mut client net.TcpConn) ! {
		// 	mut reader := io.new_buffered_reader(reader: client)
		// 	defer {
		// 		unsafe {
		// 			reader.free()
		// 		}
		// 	}
		// 	mut bytes := reader.read_line() or {return}
		// 	client.close() or { println('${err}') }
		// 	println(bytes)
		// }
		// spawn read_resp(mut client)
		// println('writing something')
		client.write('PUT default hello world ...${n}\r\n\r\n'.bytes())!
		println('written something')
		client.close()!
	}
	// conn.write('GET:default'.bytes()) or {println('${err}')}
	mut client := net.dial_tcp('127.0.0.1:6789') or { panic('${err}') }
	client.set_read_timeout(30 * time.second)
	client.set_write_timeout(30 * time.second)
	client.write('GET default\r\n\r\n'.bytes())!
	mut bytes := io.read_all(reader: client)!
	client.close()!
	response_text := bytes.bytestr()
	println('${response_text}')
}

fn test_new_topic() {
	mut client := net.dial_tcp('127.0.0.1:6789') or { panic('${err}') }
	client.set_read_timeout(30 * time.second)
	client.set_write_timeout(30 * time.second)
	client.write('NEW qq \r\n\r\n'.bytes())!
	client.close()!

	client = net.dial_tcp('127.0.0.1:6789') or { panic('${err}') }
	client.write('PUT qq something \r\n\r\n'.bytes())!
	client.close()!

	client = net.dial_tcp('127.0.0.1:6789') or { panic('${err}') }
	client.set_read_timeout(30 * time.second)
	client.set_write_timeout(30 * time.second)
	client.write('GET qq\r\n\r\n'.bytes())!
	mut bytes := io.read_all(reader: client)!
	client.close()!
	response_text := bytes.bytestr()
	println('${response_text}')
}
