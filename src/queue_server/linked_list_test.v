module linked_list_test

import node as list_node { Node }
import linked_list { List }

fn test_list_add() {
	mut list := List[int]{}
	mut node := Node[int]{
		data: 1
	}
	list.prepend(mut node)
	assert list.size == 1
}

fn test_list_destroy() {
	mut list := List[int]{}
	mut node := Node[int]{
		data: 1
	}
	list.prepend(mut node)
	list.destroy()
	assert list.size == 0
}
