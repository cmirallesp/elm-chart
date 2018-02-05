import json

import tornado.ioloop
import tornado.web
import tornado.httpserver
import time
from tornado.options import define, options
import random
from datetime import datetime

define("port", default=8887, help="run on the given port", type=int)



class QuoteHandler(tornado.web.RequestHandler):

    def set_default_headers(self):
        print("setting headers 2222!!!")
        self.set_header("Access-Control-Allow-Origin", "*")
        self.set_header("Access-Control-Allow-Headers", "x-requested-with, content-type")
        self.set_header('Access-Control-Allow-Methods', 'POST, GET')
        self.set_header("Content-type", "application/json")

    def get(self):
        r = random.randint(-100,100)
        _now = datetime.now()
        res = { "quote": r, "tstamp": _now.strftime( "%a %d %Y, %-H:%-M:%-S") }
        self.write(json.dumps(res))

    def options(self):
        # no body
        self.set_status(204)
        self.finish()




def make_app():

    return tornado.web.Application([
       (r"/quote", QuoteHandler),
    ], autoreload=True, debug=True)


if __name__ == "__main__":
    app = make_app()
    http_server = tornado.httpserver.HTTPServer(app)
    http_server.listen(options.port)
    tornado.ioloop.IOLoop.current().start()
