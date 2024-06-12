import os
import mimetypes
import http.server
import socketserver

class RequestHandler(http.server.BaseHTTPRequestHandler):
    def sendHeader(self, status, headers):
        self.send_response(status)

        for key, value in headers.items():
            self.send_header(key, value)

        self.end_headers()

    def guessType(self, path):
        mimetype, _ = mimetypes.guess_type(path)

        return mimetype or "application/octet-stream"

    def parseArgs(self, argsString):
        argsList = argsString.split("&")
        args     = {}

        for arg in argsList:
            key, value = arg.split("=")
            args[key]  = value

        return args

    def do_GET(self):
        url = self.path.strip("/")

        if url == "":
            url = "index.html"
        elif os.path.isdir(url):
            url += "/index.html"

        file = None

        try:
            file = open(url, "rb")

            self.sendHeader(200, {"Content-Type": self.guessType(url)})
            self.wfile.write(file.read())
        except:
            error = f"No such file or directory: {self.path} ({url})"

            self.sendHeader(404, {"Content-Type": "text/plain"})
            self.wfile.write(bytes(error, encoding="utf-8"))

        if file:
            file.close()

    def do_POST(self):
        command = \
            self.rfile.read(int(self.headers["Content-Length"])) \
            .decode("UTF-8")

        self.sendHeader(200, {"Content-Type": "text/plain"})
        self.wfile.write(bytes(os.popen(command, "r").read(), encoding="utf-8"))


def tryOpen(handler, port):
    try:
        return socketserver.TCPServer(("0.0.0.0", port), handler)
    except:
        return None

handler = RequestHandler
httpd   = None
port    = 8000 - 1

while not httpd:
    port += 1

    if port >= 9000:
        print("fuck you")
        exit(1)

    httpd = tryOpen(handler, port)

print(f"Opened server on port {port} (http://localhost:{port})")

httpd.serve_forever()
