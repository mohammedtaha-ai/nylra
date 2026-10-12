"""Disposable loopback SSE fixture for the native UI click, with no provider call."""
from http.server import BaseHTTPRequestHandler, HTTPServer


class Handler(BaseHTTPRequestHandler):
    def headers_for_probe(self):
        origin = self.headers.get("Origin")
        if origin not in ("tauri://localhost", "http://tauri.localhost"):
            self.send_response(403)
            self.end_headers()
            return False
        self.send_response(200)
        self.send_header("Access-Control-Allow-Origin", origin)
        self.send_header("Access-Control-Allow-Methods", "POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "content-type")
        self.send_header("Content-Type", "text/event-stream")
        self.end_headers()
        return True

    def do_OPTIONS(self):
        self.headers_for_probe()

    def do_POST(self):
        if self.path != "/chat" or not self.headers_for_probe():
            return
        length = min(int(self.headers.get("Content-Length", "0")), 2300)
        self.rfile.read(length)
        self.wfile.write(b'event: delta\ndata: {"text":"Synthetic Lighthouse"}\n\n')
        self.wfile.write(b'event: done\ndata: {"status":"complete"}\n\n')

    def log_message(self, format, *args):
        pass


HTTPServer(("127.0.0.1", 8765), Handler).serve_forever()
