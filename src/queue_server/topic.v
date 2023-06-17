module queue_server

[heap]
pub struct Topic[T] {
pub mut:
	name string
	list LinkedList[T]
}

pub fn new_topic[T](topic_name string) Topic[T] {
	mut topic := Topic[T]{
		name: topic_name
	}
	topic.list = LinkedList[T]{}
	return topic
}

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

pub fn (mut t Topic[T]) parallel_endeq(data T) {
	for _ in 0 .. 20000 {
		spawn t.enqueue(data)
		// spawn t.dequeue()
		// spawn t.enqueue(data)
		// spawn t.enqueue(data)
		// spawn t.dequeue()
	}
	for _ in 0 .. 30000 {
		spawn t.dequeue()
		spawn t.enqueue(data)
	}

	for _ in 0 .. 100 {
		spawn t.enqueue(data)
	}
	// dump(t)
}
