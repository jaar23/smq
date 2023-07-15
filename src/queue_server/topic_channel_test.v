module channel_test

import queue_server {TopicChannel}
import time
// fn test_channel() {
// 	queue_server.channel_test()
// }

fn test_send_recv() {
	mut tc := &TopicChannel[string]{channel: chan string{}, auth: false}
	tc.start()
	// spawn tc.listen()
	tc.send('hello, world')	or {
		println('unable to send message to channel')
		return
	}
	// spawn tc.observe()
	spawn tc.send('hello, world 2')
	spawn tc.send('hello, world 3')
	tc.pause()
	time.sleep(2 * time.second)
	// tc.stop()
	// println('channel len: ${tc.channel.len}')
	spawn tc.send('hello, world 4')
	tc.resume()
	// or {
	// 	println('unable to observe channel')
	// 	return
	// }
	// for {
	// 	data := tc.recv() or {
	// 		println('unable to receive message from channel')
	// 		return
	// 	}
	// 	println('received from channel: ${data}')
	// }
}

fn test_start() {
	mut tc := TopicChannel[string]{}
	tc.start()
}
