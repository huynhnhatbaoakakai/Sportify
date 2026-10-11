from pathlib import Path
from zipfile import ZipFile
import xml.etree.ElementTree as E
import io, posixpath, json
ROOT=Path(__file__).parent
A='{http://schemas.openxmlformats.org/drawingml/2006/main}'
W='{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'
R='{http://schemas.openxmlformats.org/officeDocument/2006/relationships}'
P='{http://schemas.openxmlformats.org/presentationml/2006/main}'
rows=[]
for chapter in [1,2,5,6,7,8,9,10,13]:
    path=Path('C:/Users/20huy/Downloads')/f'Chapter {chapter:02} slides.pptx'
    record={'file':path.name,'slides':[]}
    with ZipFile(path) as z:
        pres=E.fromstring(z.read('ppt/presentation.xml'))
        rels={r.get('Id'):r.get('Target') for r in E.fromstring(z.read('ppt/_rels/presentation.xml.rels'))}
        for i,node in enumerate(pres.findall(f'.//{P}sldId'),1):
            member=posixpath.normpath('ppt/'+rels[node.get(R+'id')])
            xml=E.fromstring(z.read(member))
            rp=posixpath.dirname(member)+'/_rels/'+posixpath.basename(member)+'.rels'
            sr={r.get('Id'):posixpath.normpath(posixpath.dirname(member)+'/'+r.get('Target')) for r in E.fromstring(z.read(rp))} if rp in z.namelist() else {}
            text=[''.join(p.itertext()) for p in xml.findall('.//'+A+'t')]
            embedded=[]; unresolved=[]
            for obj in xml.findall('.//'+P+'oleObj'):
                target=sr.get(obj.get(R+'id'))
                if target and target.endswith('.docx'):
                    with ZipFile(io.BytesIO(z.read(target))) as dz:
                        d=E.fromstring(dz.read('word/document.xml'))
                        paragraphs=[''.join(t.text or '' for t in par.findall('.//'+W+'t')) for par in d.findall('.//'+W+'p')]
                        embedded.append({'member':target,'text':'\n'.join(paragraphs)})
                else: unresolved.append(target)
            notes=[]
            for target in sr.values():
                if '/notesSlides/' in target and target.endswith('.xml'):
                    notes=[''.join(t.itertext()) for t in E.fromstring(z.read(target)).findall('.//'+A+'t')]
            images=[]
            for target in sr.values():
                if '/media/' in target:
                    images.append(target)
            record['slides'].append({'number':i,'text':'\n'.join(text),'embedded':embedded,'notes':'\n'.join(notes),'unresolved':unresolved,'images':images})
    rows.append(record)
ROOT.mkdir(parents=True,exist_ok=True)
(ROOT/'SLIDES_EXTRACT.json').write_text(json.dumps(rows,ensure_ascii=False,indent=2),encoding='utf-8')
md=['# Trích xuất toàn bộ slide (text + Word nhúng + speaker notes)\n','Thứ tự lấy từ presentation.xml, không suy từ tên member. Notes tách riêng. Ảnh/Visio không được coi là đã đọc từ text.\n']
for deck in rows:
    md.append(f"## {deck['file']} — {len(deck['slides'])} slides\n")
    for s in deck['slides']:
        md.append(f"### Slide {s['number']}\n{s['text']}\n")
        for d in s['embedded']: md.append(f"Word nhúng `{d['member']}`:\n\n{d['text']}\n")
        if s['notes']: md.append('**Speaker notes (không phải nội dung slide):**\n'+s['notes']+'\n')
        if s['unresolved']: md.append('**Object chưa đọc được:** '+str(s['unresolved'])+'\n')
(ROOT/'SLIDES_EXTRACT.md').write_text('\n'.join(md),encoding='utf-8')
print(json.dumps([{'file':d['file'],'slides':len(d['slides']),'embedded_docs':sum(len(s['embedded']) for s in d['slides']),'unresolved':[(s['number'],s['unresolved']) for s in d['slides'] if s['unresolved']]} for d in rows],ensure_ascii=False,indent=2))
