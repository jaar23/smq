module queue_server

pub type TopicHandlerFn[T] = fn (args T)

// [heap]
// pub struct Topic[T] {
// pub mut:
// 	name    string
// 	list    LinkedList[T]
// 	channel ?&TopicChannel[T]
// }
[heap]
pub struct Topic[T] {
pub mut:
	name string
	list LinkedList[T]
}

pub struct TopicError {
	code    int
	message string
}

// change chan to unbuffered cap when needted to implement pub sub
pub fn Topic.new[T](topic_name string) Topic[T] {
	// mut topic := Topic[T]{
	// 	name: topic_name
	// 	list: LinkedList[T]{}
	// 	channel: &TopicChannel[T]{
	// 		channel: chan T{cap: 1}
	// 		auth: false
	// 		state: ChannelState.stop
	// 	}
	// }
	mut topic := Topic[T]{
		name: topic_name
		list: LinkedList[T]{}
	}

	return topic
}

// pub fn (mut t Topic[T]) chann el_start() {
// 	t.channel.start()
// }

pub fn (mut t Topic[T]) enqueue(data T) {
	mut node := ListNode[T]{
		data: data
	}
	t.list.append(mut node)
}

pub fn (mut t Topic[T]) dequeue() ?T {
	if t.list.is_empty() {
		return none
	}
	node := t.list.pop()
	return node?.data
}

pub fn (mut t Topic[T]) dequeue_byte() []u8 {
	if t.list.is_empty() {
		return ''.bytes()
	}
	node := t.list.pop()
	data := if n := node {
		n.data.bytes()
	} else {
		''.bytes()
	}
	println('remaining item: ${t.list.size}')
	return data
}

// pub fn (mut t Topic[T]) publish(data T) ! {
// 	if t.channel.channel.closed {
// 		return error('channel is closed')
// 	} else {
// 		println('publish data')
// 		spawn t.channel.send(data)
// 	}
// }
//
// subscribe to channel for new message
// pub fn (mut t Topic[T]) subscribe(handler TopicHandlerFn[T]) ! {
// 	spawn t.channel.subscribe(handler)
// }

// pub fn (mut t Topic[T]) subscribe_block(handler TopicHandlerFn[T]) ! {
// 	t.channel.subscribe(handler) or {
// 		println('error on result subscribed')
// 		return
// 	}
// }

// pub fn (mut t Topic[T]) parallel_endeq(data T) {
// 	for _ in 0 .. 20000 {
// 		spawn t.enqueue(data)
// 		// spawn t.dequeue()
// 		// spawn t.enqueue(data)
// 		// spawn t.enqueue(data)
// 		// spawn t.dequeue()
// 	}
// 	for _ in 0 .. 30000 {
// 		spawn t.dequeue()
// 		spawn t.enqueue(data)
// 	}
//
// 	for _ in 0 .. 100 {
// 		spawn t.enqueue(data)
// 	}
// 	// dump(t)
// }
