module linked_list_test

import queue_server
import time

fn test_list_add() {
	mut list := queue_server.LinkedList[int]{}
	for n in 0 .. 100 {
		mut node := queue_server.ListNode[int]{
			data: n
		}
		list.prepend(mut node)
	}
	// list.prepend(mut node2)
	dump(list.tail)
	assert list.size == 100
}

fn test_list_add2() {
	mut list := queue_server.LinkedList[int]{}
	for n in 0 .. 5 {
		mut node := queue_server.ListNode[int]{
			data: n
		}
		list.append2(mut node)
	}
	dump(list)
	assert list.size == 5
}

fn test_list_destroy() {
	mut list := queue_server.LinkedList[int]{}
	mut node := queue_server.ListNode[int]{
		data: 1
	}
	list.prepend(mut node)
	list.destroy()
	assert list.size == 0
}

fn test_list_add_huge() {
	mut list := queue_server.LinkedList[int]{}
	start := time.now()
	println('start: ${start}')
	for n in 0 .. 20000000 {
		mut node := queue_server.ListNode[int]{
			data: n
		}
		list.append2(mut node)
	}
	println('${time.since(start)}')
	find := time.now()
	dump(list.tail)
	// dump(list.head)
	last_node := list.find_last2()
	dump(last_node)
	println('${time.since(find)}')
	assert list.size == 20000000
}
