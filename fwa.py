#!/usr/bin/python
import web
def func():
    global x
    x = date
func()
urls = (
      '/', 'index'    )
class index:
    def GET(self):
                print x
if __name__ == "__main__": web.run(urls, globals())
