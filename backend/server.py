"""Verse analysis API using a shared app token, without user or subscription checks."""
import hmac
import json
import os
from pathlib import Path
import re
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.request import Request, urlopen

ROOT = Path(__file__).resolve().parent
for line in (ROOT / '.env').read_text().splitlines() if (ROOT / '.env').exists() else []:
    if line.strip() and not line.lstrip().startswith('#'):
        key, value = line.split('=', 1)
        os.environ.setdefault(key.strip(), value.strip())

APP_ENV = os.environ.get('APP_ENV', 'development')
if APP_ENV not in ('development', 'production'):
    raise SystemExit('APP_ENV must be development or production.')
KEY = os.environ.get('GEMINI_API_KEY', '')
TOKEN = os.environ.get('DEMO_API_TOKEN', '')
MODEL = os.environ.get('GEMINI_MODEL', 'gemini-3.5-flash-lite')
if not KEY or len(TOKEN) < 32 or not re.fullmatch(r'[A-Za-z0-9._-]+', MODEL):
    raise SystemExit('Set GEMINI_API_KEY and a random DEMO_API_TOKEN of at least 32 characters in backend/.env.')

# Bible data is authoritative; clients send references, never arbitrary prompts.
BIBLES = {}
for translation in ('KJV', 'WEB'):
    books = json.loads((ROOT / 'data' / f'{translation.lower()}.json').read_text())
    BIBLES[translation] = {
        f"{book['id']}.{chapter_number}.{verse_number}":
        (f"{book['name']} {chapter_number}:{verse_number}", text, chapter)
        for book in books
        for chapter_number, chapter in enumerate(book['chapters'], 1)
        for verse_number, text in enumerate(chapter, 1)
    }
FIELDS = ['explanation', 'deeperStudy', 'historicalContext', 'originalLanguage', 'application']
slots = threading.BoundedSemaphore(3)
rate_lock = threading.Lock()
request_times = []


def generate(verse_id, translation):
    reference, text, chapter = BIBLES[translation][verse_id]
    number = int(verse_id.rsplit('.', 1)[1])
    context = '\n'.join(f'{i + 1}: {chapter[i]}' for i in range(max(0, number - 3), min(len(chapter), number + 2)))
    prompt = f'''Explain this Bible passage in clear, warm English for a Christian reader.
Reference: {reference}; canonical ID: {verse_id}; translation: {translation}
Exact verse: {text}
Surrounding verses:\n{context}
Return five substantive sections, roughly 50–100 words each: explanation, deeper study,
historical context, original-language insight, and practical application.
Interpret in context. Distinguish facts from interpretation and acknowledge differing Christian
readings where relevant. Never invent historical facts, etymologies, quotations, or citations.
State uncertainty plainly. Do not claim to speak as God. Use plain paragraphs without markdown.
Return up to three related canonical verse IDs, e.g. JOH.1.1. Output only the requested JSON.'''
    properties = {field: {'type': 'string'} for field in FIELDS}
    properties['relatedVerseIDs'] = {'type': 'array', 'items': {'type': 'string'}, 'maxItems': 3}
    body = {'contents': [{'role': 'user', 'parts': [{'text': prompt}]}],
            'generationConfig': {'maxOutputTokens': 4096, 'responseMimeType': 'application/json',
                                 'responseJsonSchema': {'type': 'object', 'properties': properties,
                                                        'required': FIELDS + ['relatedVerseIDs']}}}
    request = Request(f'https://generativelanguage.googleapis.com/v1beta/models/{MODEL}:generateContent',
                      data=json.dumps(body).encode(), headers={'Content-Type': 'application/json',
                      'x-goog-api-key': KEY, 'Cache-Control': 'no-store'}, method='POST')
    with urlopen(request, timeout=35) as response:
        envelope = json.load(response)
    candidate = envelope['candidates'][0]
    if candidate.get('finishReason') != 'STOP':
        raise ValueError('Incomplete response')
    result = json.loads(''.join(part.get('text', '') for part in candidate['content']['parts'] if not part.get('thought')))
    if not all(isinstance(result.get(field), str) and result[field].strip() for field in FIELDS):
        raise ValueError('Invalid analysis')
    related = result.get('relatedVerseIDs')
    if not isinstance(related, list):
        raise ValueError('Invalid references')
    return {**{field: result[field] for field in FIELDS},
            'relatedVerseIDs': list(dict.fromkeys(item for item in related if isinstance(item, str) and item in BIBLES[translation]))[:3]}


class Handler(BaseHTTPRequestHandler):
    def log_message(self, *args):
        pass  # Never log authorization headers, Bible notes, or upstream secrets.

    def respond(self, status, body):
        data = json.dumps(body).encode()
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Cache-Control', 'no-store')
        self.send_header('Content-Length', str(len(data)))
        self.end_headers()
        try:
            self.wfile.write(data)
        except (BrokenPipeError, ConnectionResetError):
            pass

    def do_GET(self):
        self.respond(200 if self.path == '/health' else 404,
                     {'status': 'ok', 'mode': APP_ENV} if self.path == '/health' else {'error': 'not_found'})

    def do_POST(self):
        if self.path != '/v1/analysis':
            return self.respond(404, {'error': 'not_found'})
        if not hmac.compare_digest(self.headers.get('Authorization', ''), f'Bearer {TOKEN}'):
            return self.respond(401, {'error': 'unauthorized'})
        with rate_lock:
            now = time.monotonic()
            request_times[:] = [stamp for stamp in request_times if now - stamp < 60]
            if len(request_times) >= 10:
                return self.respond(429, {'error': 'rate_limited'})
            request_times.append(now)
        try:
            length = int(self.headers.get('Content-Length', '0'))
            if length <= 0 or length > 1024:
                raise ValueError()
            body = json.loads(self.rfile.read(length))
            verse_id, translation = body['verseID'], body['translation']
            if translation not in BIBLES or verse_id not in BIBLES[translation]:
                raise ValueError()
        except (ValueError, KeyError, TypeError):
            return self.respond(400, {'error': 'invalid_passage'})
        if not slots.acquire(blocking=False):
            return self.respond(429, {'error': 'busy'})
        try:
            self.respond(200, generate(verse_id, translation))
        except Exception:
            self.respond(503, {'error': 'ai_unavailable'})
        finally:
            slots.release()


if __name__ == '__main__':
    port = int(os.environ.get('PORT', '8787'))
    host = os.environ.get('HOST', '127.0.0.1')
    print(f'Verse analysis backend ({APP_ENV}) listening on {host}:{port}', flush=True)
    ThreadingHTTPServer((host, port), Handler).serve_forever()
