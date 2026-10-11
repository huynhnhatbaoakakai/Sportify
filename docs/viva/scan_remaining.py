from pathlib import Path
import json, zipfile, io, xml.etree.ElementTree as E, posixpath, socket, urllib.request, urllib.error, subprocess
from PIL import Image, ImageDraw
root=Path(__file__).parent
slides=json.loads((root/'SLIDES_EXTRACT.json').read_text(encoding='utf-8'))
items=[]
for deck in slides:
    with zipfile.ZipFile(Path('C:/Users/20huy/Downloads')/deck['file']) as z:
        for s in deck['slides']:
            for member in dict.fromkeys(s['images']):
                if member.endswith('.emf'): continue  # Word text previews already extracted; avoid slow GDI batch rendering.
                print('READ IMAGE',deck['file'],s['number'],member,flush=True)
                im=Image.open(io.BytesIO(z.read(member)))
                try: im.load()
                except Exception as e: print('IMAGE FAILED',deck['file'],s['number'],member,str(e));continue
                im=im.convert('RGB'); im.thumbnail((1000,650))
                items.append((f"{deck['file']} slide {s['number']} / {member}",im.copy()))
print('DIRECT IMAGES',len(items))
for batch in range(0,len(items),6):
    page=Image.new('RGB',(2000,2100),'white'); dr=ImageDraw.Draw(page)
    for j,(label,im) in enumerate(items[batch:batch+6]):
        x=(j%2)*1000;y=(j//2)*700
        dr.text((x+10,y+5),label,fill='black');page.paste(im,(x,y+35))
    path=root/f'IMAGE_SHEET_{batch//6+1:02}.jpg';page.save(path,quality=92);print(path)
report=['# HTTP smoke check chỉ đọc\n','Không POST, không thay đổi database; không chạy migration/build/test. Không khẳng định WAR deployed khớp snapshot source.\n']
for port in [8080,8081,80]:
    sock=socket.socket();sock.settimeout(1);is_open=sock.connect_ex(('127.0.0.1',port))==0;sock.close()
    report.append(f'Port {port}: '+('open' if is_open else 'closed')+'\n')
    if not is_open:continue
    for urlpath in ['/sportify/owner/access','/sportify/owner/fields','/sportify/owner/reviews','/sportify/chat']:
        url=f'http://127.0.0.1:{port}'+urlpath
        try:
            res=urllib.request.urlopen(url,timeout=12)
            body=res.read().decode('utf-8',errors='replace')
            report.append(f'GET {url}: HTTP {res.status}; final URL {res.url}; response bytes {len(body.encode())}\n')
        except urllib.error.HTTPError as e:
            body=e.read().decode('utf-8',errors='replace')
            text=__import__('re').sub('<[^>]+>',' ',body)
            report.append(f'GET {url}: HTTP {e.code}\n```text\n{text[:9000]}\n```\n')
        except Exception as e:report.append(f'GET {url}: {type(e).__name__}: {e}\n')
(root/'HTTP_SCAN.md').write_text('\n'.join(report),encoding='utf-8')
print('\n'.join(report))
r=subprocess.run(['git','-C','D:/Projects/Sportify','status','--short'],capture_output=True,text=True,encoding='utf-8',errors='replace')
print('GIT STATUS (không commit/push):\n'+r.stdout+r.stderr)
