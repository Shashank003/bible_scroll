"""Usage: python3 scripts/import_kjv.py /path/to/eng-kjv2006_vpl.zip
Source: https://ebible.org/Scriptures/eng-kjv2006_vpl.zip
"""
import json
from pathlib import Path
import re
import sys
import zipfile
NAMES = 'Genesis|Exodus|Leviticus|Numbers|Deuteronomy|Joshua|Judges|Ruth|1 Samuel|2 Samuel|1 Kings|2 Kings|1 Chronicles|2 Chronicles|Ezra|Nehemiah|Esther|Job|Psalms|Proverbs|Ecclesiastes|Song of Solomon|Isaiah|Jeremiah|Lamentations|Ezekiel|Daniel|Hosea|Joel|Amos|Obadiah|Jonah|Micah|Nahum|Habakkuk|Zephaniah|Haggai|Zechariah|Malachi|Matthew|Mark|Luke|John|Acts|Romans|1 Corinthians|2 Corinthians|Galatians|Ephesians|Philippians|Colossians|1 Thessalonians|2 Thessalonians|1 Timothy|2 Timothy|Titus|Philemon|Hebrews|James|1 Peter|2 Peter|1 John|2 John|3 John|Jude|Revelation'.split('|')
with zipfile.ZipFile(sys.argv[1]) as archive:
    books = []
    for line in archive.read('eng-kjv2006_vpl.txt').decode('utf-8-sig').splitlines():
        if not line.strip(): continue
        match = re.fullmatch(r'(\S+) (\d+):(\d+) (.+)', line)
        assert match, line
        code, chapter, verse, text = match.groups()
        chapter, verse = int(chapter), int(verse)
        if not books or books[-1]['id'] != code:
            books.append({'id': code, 'name': NAMES[len(books)], 'chapters': []})
        chapters = books[-1]['chapters']
        if chapter > len(chapters):
            assert chapter == len(chapters) + 1
            chapters.append([])
        assert verse == len(chapters[-1]) + 1
        text = re.sub(r'\s+', ' ', text.replace('¶', '').replace('[', '').replace(']', '')).strip()
        chapters[-1].append(text)
    assert len(books) == 66
    assert sum(len(b['chapters']) for b in books) == 1189
    assert sum(len(c) for b in books for c in b['chapters']) == 31102
    assert books[0]['id'] == 'GEN' and books[-1]['id'] == 'REV'
    output = Path(__file__).resolve().parents[1] / 'BibleScroll'
    (output / 'kjv.json').write_text(json.dumps(books, ensure_ascii=False, separators=(',', ':')), encoding='utf-8')
    (output / 'KJV-source.html').write_bytes(archive.read('eng-kjv2006_about.htm'))
    print('Validated 66 books, 1,189 chapters, 31,102 verses.')
