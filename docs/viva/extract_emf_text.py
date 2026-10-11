from pathlib import Path
import json, zipfile, struct
root=Path(__file__).parent
rows=[]
for d in json.loads((root/'SLIDES_EXTRACT.json').read_text(encoding='utf-8')):
    with zipfile.ZipFile(Path('C:/Users/20huy/Downloads')/d['file']) as z:
        for s in d['slides']:
            for member in dict.fromkeys(s['images']):
                if not member.endswith('.emf'):continue
                data=z.read(member); pos=0;text=[]
                while pos+8 <= len(data):
                    kind,size=struct.unpack_from('<II',data,pos)
                    if size<8 or pos+size>len(data):break
                    rec=data[pos:pos+size]
                    if kind==84 and size>=76:
                        n,off=struct.unpack_from('<II',rec,44)
                        if off+n*2<=size:text.append(rec[off:off+n*2].decode('utf-16-le',errors='replace'))
                    elif kind==83 and size>=76:
                        n,off=struct.unpack_from('<II',rec,44)
                        if off+n<=size:text.append(rec[off:off+n].decode('cp1252',errors='replace'))
                    pos+=size
                rows.append({'deck':d['file'],'slide':s['number'],'image':member,'text':'\n'.join(text)})
(root/'EMF_TEXT.json').write_text(json.dumps(rows,ensure_ascii=False,indent=2),encoding='utf-8')
print('EMF records',len(rows),'no selectable text',[(r['deck'],r['slide'],r['image']) for r in rows if not r['text']]);print('text chars',sum(len(r['text']) for r in rows))
