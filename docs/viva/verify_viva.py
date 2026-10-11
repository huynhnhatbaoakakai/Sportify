from pathlib import Path
import json,re,hashlib,collections,datetime
p=Path(__file__).parent;root=p.parents[1]
main=(p/'SPORTIFY_VIVA_MAP.md').read_text(encoding='utf-8')
slides=json.loads((p/'SLIDES_EXTRACT.json').read_text(encoding='utf-8'))
flows=json.loads((p/'FUNCTION_FLOWS.json').read_text(encoding='utf-8'))
manifest=json.loads((p/'SOURCE_MANIFEST.json').read_text(encoding='utf-8'))
checks={}
checks['all_required_sections']=all(f'## {n}.' in main for n in range(1,10))
checks['no_unfilled_placeholders']='_INSERT -->' not in main
checks['all_flows_13_steps']=len(flows)==10 and all(len(s)==13 for s in flows.values())
q30=main.split('### 7.1 ',1)[1].split('### 7.2 ',1)[0]
q10=main.split('### 7.2 ',1)[1].split('## 8.',1)[0]
checks['30_questions']=len(re.findall(r'^\d+\. ',q30,re.M))==30
checks['10_deep_questions']=len(re.findall(r'^\d+\. ',q10,re.M))==10
links=re.findall(r'\]\(([^)]+)\)',main)
missing=[]
for link in links:
 if '://' in link or link.startswith('#'):continue
 target=link.split('#',1)[0]
 if not (p/target).exists():missing.append(link)
checks['all_markdown_links_exist']=not missing
changed=[]
for f in manifest['files']:
 source=root/f['path']
 if not source.is_file() or hashlib.sha256(source.read_bytes()).hexdigest()!=f['sha256']:changed.append(f['path'])
checks['source_snapshot_unchanged_since_manifest']=not changed
checks['reported_removed_sql_absent']=not (root/'database/reviews.sql').exists() and not (root/'database/README.md').exists()
checks['java_production20']=sum(1 for x in (root/'src/main/java').rglob('*.java'))==20
# Verify each slide position is covered exactly once by group table.
text=(p/'SLIDE_PROJECT_MAP.md').read_text(encoding='utf-8').split('## 3. Bảng học theo chương',1)[1].split('## 4. Speaker notes',1)[0]
coverage={}; chapter=None;groups=0
for line in text.splitlines():
 m=re.match(r'### Chapter(\d+)',line)
 if m:chapter=int(m.group(1));coverage[chapter]=[]
 m=re.match(r'\| (\d+)(?:[–-](\d+))? \|',line)
 if m and chapter:
  a=int(m.group(1));b=int(m.group(2) or a);coverage[chapter].extend(range(a,b+1));groups+=1
coverage_ok=True
for deck in slides:
 c=int(re.search(r'Chapter (\d+)',deck['file']).group(1));nums=[s['number'] for s in deck['slides']]
 if collections.Counter(coverage.get(c,[]))!=collections.Counter(nums):coverage_ok=False
checks['slide354_coverage125_groups']=coverage_ok and sum(len(d['slides']) for d in slides)==354 and groups==125
report={'verified_at_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'checks':checks,'flow_count':len(flows),'flow_step_count':sum(len(v) for v in flows.values()),'slides':sum(len(d['slides']) for d in slides),'slide_groups':groups,'questions':[30,10],'missing_links':missing,'changed_source_since_manifest':changed,'artifact':str(p/'SPORTIFY_VIVA_MAP.md'),'artifact_bytes':len(main.encode('utf-8')),'artifact_sha256':hashlib.sha256(main.encode('utf-8')).hexdigest(),'runtime_limit':'Only DB SELECT metadata/count and HTTP GET; no Maven/JSP compilation or POST writes.'}
(p/'VIVA_VERIFICATION.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(report,ensure_ascii=False,indent=2))
if not all(checks.values()):raise SystemExit(1)
