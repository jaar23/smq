module queue_server

[heap]
pub struct ListNode[T] {
pub mut:
	data T
	next ?&ListNode[T]
}

pub fn (mut n ListNode[T]) add_after(mut node ListNode[T]) {
	// if mut next_node := n.next {
	// 	next_node = node
	// }
	n.next = node
}
