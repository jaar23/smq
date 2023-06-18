module queue_server

// import time

pub enum ChannelState {
	pause
	resume
	stop
	start
}

pub struct TopicChannel[T] {
mut:
	channel chan T
	auth    bool
	state   ChannelState
}

pub fn (mut t TopicChannel[T]) send(data T) ! {
	t.channel <- data
}

pub fn (mut t TopicChannel[T]) recv() !T {
	data := <- t.channel
	return data
}

pub fn (mut t TopicChannel[T]) listen() ! {
	for {
		if t.state == ChannelState.stop {
			break
		}
		if t.state == ChannelState.start || t.state == ChannelState.resume {
			data := t.recv() or {
				eprintln('no message received yet')
				continue
			}
			eprintln('received from channel ${data}')
		}
	}
	println('channel exit..')
}


pub fn (mut t TopicChannel[T]) subscribe(handler TopicHandlerFn[T]) ! {
	for {
		if t.state == ChannelState.stop {
			break
		}
		if t.state == ChannelState.start || t.state == ChannelState.resume {
			data := t.recv() or {
				eprintln('no message received yet')
				continue
			}
			eprintln('received from channel ${data}')
			handler(data)
		}
	}
	println('channel exit..')
}

pub fn (mut t TopicChannel[T]) pause() {
	t.state = ChannelState.pause
	println('channel is paused')
}

pub fn (mut t TopicChannel[T]) resume() {
	t.state = ChannelState.resume
	println('channel is resume')
}

pub fn (mut t TopicChannel[T]) stop() {
	t.state = ChannelState.stop
	println('channel is stop')
}

pub fn (mut t TopicChannel[T]) start() {
	t.state = ChannelState.start
	t.channel = chan T{}
	println('channel started')
}


// pub fn (mut t TopicChannel[T]) observe() {
// 	for {
// 		select {
// 			ch_data := <- t.channel {
// 				eprintln('> data: ${ch_data}')
// 			}
// 			500 * time.millisecond {
// 				eprintln('> more than 0.5s passed without a channel being ready')
// 			}
// 		}
// 	}
// 	eprintln('> done')
// }
//
// fn channel_test() {
// 	println('running channel')
// 	ch1 := chan int{cap: 1}
// 	ch2 := chan string{cap: 1}
//
// 	ch1 <- 9
// 	ch2 <- 'hello'
//
// 	num := <-ch1
// 	str := <-ch2
//
// 	println('num: ${num}')
// 	println('string: ${str}')
// }
//
// fn main() {
// 	mut tc := &TopicChannel[string]{channel: chan string{}, auth: false}
	// spawn tc.observe()
	// spawn tc.listen()
	// tc.send('hello, world') or {
	// 	println('unable to send message')
	// 	return
	// }
	// spawn tc.send('hello, world 2')
	// spawn tc.send('hello, world 3')
	// t := spawn tc.send('hello, world 4')
	// // spawn fn[T](mut tc TopicChannel[T], data T) {
	// 	println('call after 5 sec')
	// 	time.sleep(5 * time.second)
	// 	*tc.send(data) or {
	// 		panic('unable to send to channel after channel is listening')
	// 	}
	// }(mut tc, 'hhhhhhhhhhhhhh')
	// spawn tc.listen()
	// time.sleep(5 * time.second)
	// t.wait()
	// for {
		// tc.send('cvcvcvcvcvc')
	// }
// }
