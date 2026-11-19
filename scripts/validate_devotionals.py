"""Validate the December 2026 / January 2027 devotional content library."""
import datetime as dt
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
entries = json.loads((ROOT / 'BibleScroll/devotionals.json').read_text())
books = json.loads((ROOT / 'BibleScroll/kjv.json').read_text())
verses = {f"{book['id']}.{chapter + 1}.{number + 1}": text
          for book in books for chapter, texts in enumerate(book['chapters'])
          for number, text in enumerate(texts)}
start, end = dt.date(2026, 12, 1), dt.date(2027, 1, 31)
expected = {(start + dt.timedelta(days=offset)).isoformat() for offset in range((end - start).days + 1)}
assert len(entries) == 62
assert len({entry['id'] for entry in entries}) == 62
assert {entry['date'] for entry in entries} == expected
assert len({entry['title'] for entry in entries}) == 62
assert len({entry['reflection'] for entry in entries}) == 62
for entry in entries:
    date = dt.date.fromisoformat(entry['date'])
    assert entry['id'] == date.isoformat()
    assert entry['seriesDay'] == date.day
    for field in ['series', 'title', 'introduction', 'reflection', 'application', 'prayer', 'author']:
        assert entry[field].strip(), (entry['date'], field)
    assert entry['scriptureReferences']
    assert len(entry['scriptureReferences']) == len(set(entry['scriptureReferences']))
    for reference in entry['scriptureReferences']:
        assert reference in verses, (entry['date'], reference)
    assert len(entry['reflection'].split()) >= 90, entry['date']
    assert len(entry['prayer'].split()) >= 15, entry['date']
    assert not any(word in json.dumps(entry).lower() for word in ['lorem', 'ipsum', 'placeholder', 'demo content'])
print('Passed: 62 unique dates and titles, complete daily coverage, required fields, substantial original reflections, prayers, and all Scripture references.')
print('December:', sum(entry['date'].startswith('2026-12') for entry in entries))
print('January:', sum(entry['date'].startswith('2027-01') for entry in entries))
print('Total original content words:', sum(len(' '.join(entry[field] for field in ['introduction','reflection','application','prayer']).split()) for entry in entries))
