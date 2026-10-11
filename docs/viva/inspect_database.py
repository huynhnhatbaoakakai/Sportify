from pathlib import Path
import xml.etree.ElementTree as E
import subprocess, os
root=Path(__file__).resolve().parents[2]
x=E.parse(root/'src/main/resources/META-INF/persistence.xml')
p={e.get('name'):e.get('value') for e in x.iter() if e.tag.endswith('property')}
env=os.environ.copy(); env['PGPASSWORD']=p['jakarta.persistence.jdbc.password']; env['PGCONNECT_TIMEOUT']='5'; env['PGOPTIONS']='-c default_transaction_read_only=on'
url=p['jakarta.persistence.jdbc.url']; hostport,db=url.split('//',1)[1].split('/',1); host,port=hostport.split(':')
queries=[('IDENTITY_AND_LENGTHS',"SELECT table_name, column_name, is_identity, identity_generation, character_maximum_length, numeric_precision, numeric_scale FROM information_schema.columns WHERE table_schema='public' ORDER BY table_name,ordinal_position;"),('INDEXES',"SELECT tablename,indexname,indexdef FROM pg_indexes WHERE schemaname='public' ORDER BY tablename,indexname;"),('SERVER',"SELECT current_database(), current_user, version();"),('TABLES',"SELECT table_schema, table_name FROM information_schema.tables WHERE table_schema NOT IN ('pg_catalog','information_schema') ORDER BY 1,2;"),('COLUMNS',"SELECT table_schema, table_name, column_name, data_type, is_nullable, column_default FROM information_schema.columns WHERE table_schema='public' ORDER BY table_name, ordinal_position;"),('CONSTRAINTS',"SELECT conrelid::regclass AS table_name, conname, contype, pg_get_constraintdef(oid) FROM pg_constraint WHERE connamespace = 'public'::regnamespace ORDER BY 1,2;"),('COUNTS',"SELECT 'sports_fields' AS table_name, count(*) FROM sports_fields UNION ALL SELECT 'chat_messages',count(*) FROM chat_messages UNION ALL SELECT 'reviews',count(*) FROM reviews;"),('OWNER_DISTRIBUTION',"SELECT owner_id, count(*) AS fields FROM sports_fields GROUP BY owner_id ORDER BY owner_id;"),('REVIEW_SUMMARY',"SELECT f.owner_id, count(r.review_id), avg(r.rating), count(r.owner_reply) AS replied FROM sports_fields f LEFT JOIN reviews r ON r.field_id=f.field_id GROUP BY f.owner_id ORDER BY f.owner_id;")]
report=['# Kiểm tra PostgreSQL chỉ đọc\n','Không sửa schema/data, không xuất nội dung tin nhắn hoặc thông tin cá nhân. PGOPTIONS default_transaction_read_only=on.\n']
for name,query in queries:
    r=subprocess.run(['C:/Program Files/PostgreSQL/18/bin/psql.exe','-X','-w','-h',host,'-p',port,'-U',p['jakarta.persistence.jdbc.user'],'-d',db,'-c',query],env=env,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=20)
    report.append('## '+name+'\n```sql\n'+query+'\n```\n```text\n'+r.stdout+r.stderr+'\n```\nExit code: '+str(r.returncode)+'\n')
    print(name, 'exit',r.returncode, r.stdout[:1500],r.stderr[:500])
(root/'docs/viva/DATABASE_SCAN.md').write_text('\n'.join(report),encoding='utf-8')
