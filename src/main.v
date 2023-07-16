module main

import os
import flag
import queue_server as qs
import term

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('smq')
	fp.version('0.1.1')
	fp.description('Simple queue server')
	fp.skip_executable()

	config_file := fp.string('config', `c`, 'none', 'The config file path')

	additional_args := fp.finalize()!

	if additional_args.len > 0 {
		println('Unprocessed arguments:\n$additional_args.join_lines()')
	}
	start_with_config(config_file)!
	// println(config_file)
}

fn start_with_config(config_file string) ! {
	println(term.blue('smq initialize with config file'))
	mut queue := qs.init_queue_with_config[string](config_file)!
	println(term.bold(term.green('smq initialize successfully!')))
	queue.listen()
}
