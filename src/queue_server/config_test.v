module config_test

import queue_server as qs


pub fn test_config() ! {
	config := qs.read_config('../../config.toml') or {panic('${err}')}
	dump(config)
	println('queue addr ${config.value('queue.addr').string()}')
	println('queue topics ${config.value('queue.topics').array()}')
	println('queue topics ${config.value('queue.topics').array().len}')
	for n in 0..config.value('queue.topics').array().len {
		println(config.value('queue.topics').array()[n].value('name').string())
	}
}

pub fn test_config_init_queue() {
	queue := qs.init_queue_with_config[string]('../../config.toml') or {panic('${err}')}
	println(queue.topic.len)
}
