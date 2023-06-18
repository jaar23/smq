module queue_server

[heap]
pub struct Queue[T] {
	topic []Topic[T]
	port  int
	state QueueState
}

pub enum QueueState {
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

pub fn (mut q Queue[T]) new_topic(mut topic Topic[T]) {
	q.topic << topic
}

pub fn (q Queue[T]) get_topic(topic_name string) ?&Topic {
	for i in 0 .. q.topic.len {
		if topic_name == q.topic[i].topic.name {
			return q.topic[i]
		}
	}
	return none
}

pub fn (mut q Queue[T]) set_port(port int) {
	q.port = port
}

pub fn (q Queue[T]) get_port() {
	return q.port
}

pub fn (mut q Queue[T]) put(topic_name string, data T) ! {
	topic := q.get_topic(topic_name) or {
		return QueueError{
			code: 1
			error_message: 'Topic not found'
		}
	}
	topic.enqueue(data)
}

pub fn (mut q Queue[T]) get(topic_name string, data T) !T {
	topic := q.get_topic(topic_name) or {
		return QueueError{
			code: 1
			error_message: 'Topic not found'
		}
	}
	return topic.dequeue()
}
