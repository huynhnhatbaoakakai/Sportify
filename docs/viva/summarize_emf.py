from pathlib import Path
import json,re
p=Path(__file__).parent
em=json.loads((p/'EMF_TEXT.json').read_text(encoding='utf-8'))
slides=json.loads((p/'SLIDES_EXTRACT.json').read_text(encoding='utf-8'))
lookup={(d['file'],s['number']):s for d in slides for s in d['slides']}
novel=[]
for r in em:
 s=lookup[(r['deck'],r['slide'])]
 norm=lambda x:re.sub(r'\s+','',x).casefold()
 body=norm(s['text']+' '.join(x['text'] for x in s['embedded']))
 lines=[x for x in r['text'].splitlines() if norm(x) and norm(x) not in body]
 if lines:novel.append((r,lines))
out=['# Text EMF bổ sung ngoài Word nhúng\n','Text lấy từ EMR_EXTTEXTOUT, không suy vị trí/mũi tên từ thứ tự text.\n']
for r,lines in novel:out.append(f"## {r['deck']} slide {r['slide']} — {r['image']}\n"+'\n'.join(lines)+'\n')
(p/'EMF_NOVEL.md').write_text('\n'.join(out),encoding='utf-8')
print('records with additional text',len(novel),'chars',sum(len('\n'.join(ls)) for _,ls in novel))
