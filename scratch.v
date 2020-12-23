//eg: https://github.com/vlang/v/blob/master/doc/docs.md#hello-world
//fn main() {	println('hello world') }
//https://vlang.io/compare#go
/*
const (
	StoriesUrl = 'https://hacker-news.firebaseio.com/v0/topstories.json'
	ItemUrlBase = 'https://hacker-news.firebaseio.com/v0/item'
)

struct Story {
    title string
}

fn main() {
    resp := http.get(StoriesUrl)?
    ids := json.decode([]int, resp.body)?
    mut cursor := 0
    for _ in 0..8 {
        go fn() {
            for {
                lock {
                    if cursor >= ids.len {
                        break
                    }
                    id := ids[cursor]
                    cursor++
                }
                resp := http.get('$ItemUrlBase/$id.json')?
                story := json.decode(Story, resp.body)?
                println(story.title)
            }
        }()
    }
    runtime.wait()
}
*/
module main

import time
import os

[live]
fn print_message() {
	println('World! Modify this message while the program is running.')
}

fn main() {
	for {
		print_message()
		time.sleep_ms(500)
	}
}
