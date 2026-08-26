#!/usr/bin/env python3
"""Anthropic-API shim in front of Ollama for Claude Code.

Ollama's /v1/messages defaults thinking ON when the request omits the
`thinking` field, and those thinking tokens count toward max_tokens --
which makes Claude Code die with "response exceeded the N output token
maximum". This proxy forces thinking off and clamps max_tokens.

It also pins a user-role text block into the newest turn; see
_pin_user_query for why the qwen3.8 renderer needs one to exist.
"""
import json
import os
import sys
import urllib.request
import urllib.error
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

UPSTREAM = os.environ.get("OLLAMA_HOST_URL", "http://127.0.0.1:11434")
LISTEN_PORT = int(os.environ.get("CC_PROXY_PORT", "11435"))
MAX_TOKENS_CAP = int(os.environ.get("CC_PROXY_MAX_TOKENS", "8192"))
VERBOSE = os.environ.get("CC_PROXY_VERBOSE", "1") == "1"
SAMPLING = os.environ.get("CC_PROXY_SAMPLING", "1") == "1"
TEMPERATURE = float(os.environ.get("CC_PROXY_TEMPERATURE", "0.7"))
TOP_P = float(os.environ.get("CC_PROXY_TOP_P", "0.8"))
USER_QUERY_PIN = os.environ.get(
    "CC_PROXY_USER_QUERY_PIN", "Continue with the task above.")


def log(msg):
    if VERBOSE:
        print(f"[cc-proxy] {msg}", file=sys.stderr, flush=True)


class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def log_message(self, *args):
        pass

    def _proxy(self, method):
        length = int(self.headers.get("content-length") or 0)
        body = self.rfile.read(length) if length else b""

        if method == "POST" and self.path.endswith("/v1/messages") and body:
            body = self._rewrite(body)

        headers = {
            k: v for k, v in self.headers.items()
            if k.lower() not in ("host", "content-length", "connection",
                                 "accept-encoding")
        }
        headers["content-length"] = str(len(body))
        headers["accept-encoding"] = "identity"

        req = urllib.request.Request(
            UPSTREAM + self.path, data=body or None, headers=headers,
            method=method,
        )
        try:
            upstream = urllib.request.urlopen(req, timeout=1800)
        except urllib.error.HTTPError as e:
            upstream = e
        except Exception as e:
            log(f"upstream error: {e}")
            self.send_response(502)
            self.send_header("content-type", "application/json")
            payload = json.dumps({
                "type": "error",
                "error": {"type": "api_error", "message": str(e)},
            }).encode()
            self.send_header("content-length", str(len(payload)))
            self.end_headers()
            self.wfile.write(payload)
            return

        with upstream:
            self.send_response(upstream.status)
            for k, v in upstream.headers.items():
                if k.lower() in ("transfer-encoding", "content-length",
                                 "connection", "content-encoding"):
                    continue
                self.send_header(k, v)
            self.send_header("transfer-encoding", "chunked")
            self.end_headers()
            # Stream SSE through unbuffered so Claude Code renders live.
            while True:
                chunk = upstream.read1(8192) if hasattr(upstream, "read1") \
                    else upstream.read(8192)
                if not chunk:
                    break
                self.wfile.write(f"{len(chunk):X}\r\n".encode())
                self.wfile.write(chunk)
                self.wfile.write(b"\r\n")
                self.wfile.flush()
            self.wfile.write(b"0\r\n\r\n")
            self.wfile.flush()

    def _rewrite(self, body):
        try:
            data = json.loads(body)
        except Exception:
            return body
        was = data.get("thinking", "<omitted>")
        req_max = data.get("max_tokens")
        data["thinking"] = {"type": "disabled"}
        if not isinstance(req_max, int) or req_max > MAX_TOKENS_CAP:
            data["max_tokens"] = MAX_TOKENS_CAP
        if SAMPLING:
            data.setdefault("temperature", TEMPERATURE)
            data.setdefault("top_p", TOP_P)
        pinned = self._pin_user_query(data)
        log(f"thinking={was} -> disabled | max_tokens={req_max} -> "
            f"{data['max_tokens']} | stream={data.get('stream')} | "
            f"pin={pinned}")
        return json.dumps(data).encode()

    @staticmethod
    def _pin_user_query(data):
        """Keep a user-role text block in the newest turn.

        Ollama drops the oldest messages when a conversation outgrows
        num_ctx. In an agentic loop the oldest message is the only real
        user turn: every later one carries tool_result blocks alone, and
        those map to role "tool", not "user". Once the first turn is gone
        the qwen3.8 renderer aborts the request with "no user query found
        in messages" -- a 500 that Claude Code retries ten times and that
        fails identically every time, because the message list it resends
        is the same one.

        The last turn is the one truncation cannot reach, so a text block
        there always survives. Claude Code already sends text alongside
        tool_result blocks in that position (its own system-reminders),
        so this is a shape the model is used to seeing.
        """
        msgs = data.get("messages")
        if not isinstance(msgs, list) or not msgs:
            return False
        last = msgs[-1]
        if not isinstance(last, dict) or last.get("role") != "user":
            return False
        content = last.get("content")
        if not isinstance(content, list):
            return False  # a plain string is already a user query
        if any(isinstance(b, dict) and b.get("type") == "text"
               for b in content):
            return False
        content.append({"type": "text", "text": USER_QUERY_PIN})
        return True

    def do_POST(self):
        self._proxy("POST")

    def do_GET(self):
        self._proxy("GET")


if __name__ == "__main__":
    log(f"listening on 127.0.0.1:{LISTEN_PORT} -> {UPSTREAM} "
        f"(max_tokens cap {MAX_TOKENS_CAP})")
    ThreadingHTTPServer(("127.0.0.1", LISTEN_PORT), Handler).serve_forever()
