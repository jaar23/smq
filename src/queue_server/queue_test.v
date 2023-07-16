module queue_test

import time
import net
import io
import queue_server as qs

fn test_queue_listen() {
	// mut t := queue_server.new_topic[string]
	// ('test topic')
	// mut q := Queue[string]{
	// 	port: 6789
	// }
	// q.new_topic(mut t)
	mut queue := qs.init_queue[string]()
	print_msg := fn (message string) {
		println(message)
	}
	// queue.topic[0].subscribe(print_msg) or { println('${err}') }
	queue.listen()
}

// fn test_queue_write() {
// 	mut client := net.dial_tcp('127.0.0.1:6789') or { panic('${err}') }
// 	client.set_read_timeout(30 * time.second)
// 	client.set_write_timeout(30 * time.second)
// 	// read_resp := fn (mut client net.TcpConn) ! {
// 	// 	mut reader := io.new_buffered_reader(reader: client)
// 	// 	defer {
// 	// 		unsafe {
// 	// 			reader.free()
// 	// 		}
// 	// 	}
// 	// 	mut bytes := reader.read_line() or {return}
// 	// 	client.close() or { println('${err}') }
// 	// 	println(bytes)
// 	// }
// 	// spawn read_resp(mut client)
// 	println('writing something')
// 	client.write('GET default\r\n\r\n'.bytes())!
// 	println('written something')
// 	mut bytes := io.read_all(reader: client)!
// 	client.close()!
// 	response_text := bytes.bytestr()
// 	println('${response_text}')
// 	// conn.write('GET:default'.bytes()) or {println('${err}')}
// }
