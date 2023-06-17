module queue_server

pub struct LinkedList[T] {
mut:
	head ?&ListNode[T]
	size int
}

pub fn (l LinkedList[T]) size() int {
	return l.size
}

pub fn (l LinkedList[T]) is_empty() bool {
	if l.size() > 0 {
		return false
	} else {
		return true
	}
}

pub fn (mut l LinkedList[T]) prepend(mut node ListNode[T]) {
	if head := l.head {
		node.next = head
		l.head = node
		l.size = l.size + 1
	} else {
		l.head = node
		l.size = 1
	}
}

pub fn (mut l LinkedList[T]) append(mut node ListNode[T]) ?int {
	if l.head == none {
		l.head = node
		l.size = 1
		return l.size
	}
	mut curr_node := l.head
	for {
		if curr_node != none {
			if next_node := curr_node?.next {
				curr_node = next_node
			} else {
				curr_node?.next = node
				l.size = l.size + 1
				break
			}
		}
	}
	return l.size
}

pub fn (l LinkedList[T]) find_last() ?&ListNode[T] {
	mut curr_node := l.head
	for {
		if curr_node != none {
			if next_node := curr_node?.next {
				curr_node = next_node
			} else {
				println('found node, its data: ${curr_node?.data}')
				break
			}
		}
	}
	return curr_node
}

pub fn (l LinkedList[T]) find_at(pos int) ?&ListNode[T] {
	mut curr_node := l.head
	if pos == 0 {
		return curr_node
	} else if pos > l.size {
		return none
	} else if pos == l.size {
		return l.find_last()
	} else {
		for i in 0 .. l.size {
			if i == pos {
				return curr_node
			} else {
				if next_node := curr_node?.next {
					curr_node = next_node
				}
			}
		}
	}
	return curr_node
}

pub fn (mut l LinkedList[T]) add_after(mut cursor_node ListNode[T], mut node ListNode[T]) ?&ListNode[T] {
	cursor_node.add_after(mut node)
	l.size = l.size + 1
	println('node: ${ptr_str(node)}')
	// unsafe {
	// 	if cursor_node != nil {
	// 		return unwrap_node.next
	// 	} else {
	// 		return nil
	// 	}
	return cursor_node.next
	// }
}

pub fn (mut l LinkedList[T]) delete_at(pos int) ?bool {
	mut curr_node := l.head
	mut prev_node := l.head
	if pos == 0 {
		l.head = curr_node?.next
		l.size = l.size - 1
		return true
		// if mut next_node := curr_node?.next {
		// 	println('next_node data: ${next_node.data}')
		// 	l.head = next_node.next
		// 	l.size = l.size - 1
		// 	return true
		// }
		// following code fail to compile
		// error: cannot convert 'struct _option_main__LinkedListNode_T_string_ptr' to 'struct main__Node_T_string *'
		// l.head = curr_node?.next
		// l.size = l.size - 1
		// return true
	}
	if pos > l.size {
		return false
	}
	for i in 0 .. l.size {
		if i == pos {
			if mut next_node := curr_node?.next {
				// prev_node?.add_after(mut next_node)
				println('deleting')
				prev_node?.next = next_node
				l.size = l.size - 1
			}
			break
			return true
		} else {
			if curr_node != none {
				if mut next_node := curr_node?.next {
					prev_node = curr_node
					curr_node = &next_node
				} else {
					return false
				}
			}
		}
	}
	return false
}

pub fn (mut l LinkedList[T]) destroy() {
	mut cursor_node := l.head
	for _ in 0 .. l.size {
		if mut curr_node := cursor_node {
			if mut next_node := curr_node.next {
				l.head = &next_node
			}
		}
	}
	l.size = 0
	l.head = none
}

pub fn (mut l LinkedList[T]) pop() ?&ListNode[T] {
	curr_node := l.head
	l.head = l.head?.next
	l.size = l.size - 1
	return curr_node
}

pub fn (l LinkedList[T]) count() ?int {
	mut idx := 1
	mut curr_node := l.head
	println(curr_node?.data)
	if curr_node == none {
		return idx
	}
	for {
		if curr_node != none {
			if next_node := curr_node?.next {
				curr_node = next_node
				idx = idx + 1
			} else {
				break
			}
		}
	}
	return idx
}
