# Kiểm tra PostgreSQL chỉ đọc

Không sửa schema/data, không xuất nội dung tin nhắn hoặc thông tin cá nhân. PGOPTIONS default_transaction_read_only=on.

## IDENTITY_AND_LENGTHS
```sql
SELECT table_name, column_name, is_identity, identity_generation, character_maximum_length, numeric_precision, numeric_scale FROM information_schema.columns WHERE table_schema='public' ORDER BY table_name,ordinal_position;
```
```text
  table_name   |  column_name   | is_identity | identity_generation | character_maximum_length | numeric_precision | numeric_scale 
---------------+----------------+-------------+---------------------+--------------------------+-------------------+---------------
 chat_messages | message_id     | NO          |                     |                          |                64 |             0
 chat_messages | sender_name    | NO          |                     |                      100 |                   |              
 chat_messages | receiver_name  | NO          |                     |                      100 |                   |              
 chat_messages | message_text   | NO          |                     |                     1000 |                   |              
 chat_messages | sent_at        | NO          |                     |                          |                   |              
 reviews       | review_id      | YES         | BY DEFAULT          |                          |                64 |             0
 reviews       | field_id       | NO          |                     |                          |                64 |             0
 reviews       | customer_name  | NO          |                     |                      100 |                   |              
 reviews       | rating         | NO          |                     |                          |                32 |             0
 reviews       | comment        | NO          |                     |                          |                   |              
 reviews       | owner_reply    | NO          |                     |                          |                   |              
 reviews       | created_at     | NO          |                     |                          |                   |              
 reviews       | replied_at     | NO          |                     |                          |                   |              
 sports_fields | field_id       | YES         | BY DEFAULT          |                          |                64 |             0
 sports_fields | owner_id       | NO          |                     |                          |                64 |             0
 sports_fields | field_name     | NO          |                     |                      150 |                   |              
 sports_fields | sport_type     | NO          |                     |                       30 |                   |              
 sports_fields | address        | NO          |                     |                      255 |                   |              
 sports_fields | description    | NO          |                     |                          |                   |              
 sports_fields | price_per_hour | NO          |                     |                          |                12 |             2
 sports_fields | open_time      | NO          |                     |                          |                   |              
 sports_fields | close_time     | NO          |                     |                          |                   |              
 sports_fields | image_url      | NO          |                     |                      500 |                   |              
 sports_fields | status         | NO          |                     |                       20 |                   |              
 sports_fields | created_at     | NO          |                     |                          |                   |              
 sports_fields | updated_at     | NO          |                     |                          |                   |              
(26 rows)


```
Exit code: 0

## INDEXES
```sql
SELECT tablename,indexname,indexdef FROM pg_indexes WHERE schemaname='public' ORDER BY tablename,indexname;
```
```text
   tablename   |              indexname              |                                                          indexdef                                                           
---------------+-------------------------------------+-----------------------------------------------------------------------------------------------------------------------------
 chat_messages | chat_messages_pkey                  | CREATE UNIQUE INDEX chat_messages_pkey ON public.chat_messages USING btree (message_id)
 reviews       | idx_reviews_field_created           | CREATE INDEX idx_reviews_field_created ON public.reviews USING btree (field_id, created_at DESC, review_id DESC)
 reviews       | reviews_pkey                        | CREATE UNIQUE INDEX reviews_pkey ON public.reviews USING btree (review_id)
 sports_fields | sports_fields_pkey                  | CREATE UNIQUE INDEX sports_fields_pkey ON public.sports_fields USING btree (field_id)
 sports_fields | uq_sports_fields_owner_name_address | CREATE UNIQUE INDEX uq_sports_fields_owner_name_address ON public.sports_fields USING btree (owner_id, field_name, address)
(5 rows)


```
Exit code: 0

## SERVER
```sql
SELECT current_database(), current_user, version();
```
```text
 current_database | current_user |                                 version                                 
------------------+--------------+-------------------------------------------------------------------------
 sporttrent       | postgres     | PostgreSQL 18.6 on x86_64-windows, compiled by msvc-19.44.35228, 64-bit
(1 row)


```
Exit code: 0

## TABLES
```sql
SELECT table_schema, table_name FROM information_schema.tables WHERE table_schema NOT IN ('pg_catalog','information_schema') ORDER BY 1,2;
```
```text
 table_schema |  table_name   
--------------+---------------
 public       | chat_messages
 public       | reviews
 public       | sports_fields
(3 rows)


```
Exit code: 0

## COLUMNS
```sql
SELECT table_schema, table_name, column_name, data_type, is_nullable, column_default FROM information_schema.columns WHERE table_schema='public' ORDER BY table_name, ordinal_position;
```
```text
 table_schema |  table_name   |  column_name   |          data_type          | is_nullable |                  column_default                   
--------------+---------------+----------------+-----------------------------+-------------+---------------------------------------------------
 public       | chat_messages | message_id     | bigint                      | NO          | nextval('chat_messages_message_id_seq'::regclass)
 public       | chat_messages | sender_name    | character varying           | NO          | 
 public       | chat_messages | receiver_name  | character varying           | NO          | 
 public       | chat_messages | message_text   | character varying           | NO          | 
 public       | chat_messages | sent_at        | timestamp without time zone | NO          | CURRENT_TIMESTAMP
 public       | reviews       | review_id      | bigint                      | NO          | 
 public       | reviews       | field_id       | bigint                      | NO          | 
 public       | reviews       | customer_name  | character varying           | NO          | 
 public       | reviews       | rating         | integer                     | NO          | 
 public       | reviews       | comment        | text                        | NO          | 
 public       | reviews       | owner_reply    | text                        | YES         | 
 public       | reviews       | created_at     | timestamp without time zone | NO          | CURRENT_TIMESTAMP
 public       | reviews       | replied_at     | timestamp without time zone | YES         | 
 public       | sports_fields | field_id       | bigint                      | NO          | 
 public       | sports_fields | owner_id       | bigint                      | NO          | 1
 public       | sports_fields | field_name     | character varying           | NO          | 
 public       | sports_fields | sport_type     | character varying           | NO          | 
 public       | sports_fields | address        | character varying           | NO          | 
 public       | sports_fields | description    | text                        | YES         | 
 public       | sports_fields | price_per_hour | numeric                     | NO          | 
 public       | sports_fields | open_time      | time without time zone      | NO          | 
 public       | sports_fields | close_time     | time without time zone      | NO          | 
 public       | sports_fields | image_url      | character varying           | YES         | 
 public       | sports_fields | status         | character varying           | NO          | 'ACTIVE'::character varying
 public       | sports_fields | created_at     | timestamp without time zone | NO          | CURRENT_TIMESTAMP
 public       | sports_fields | updated_at     | timestamp without time zone | NO          | CURRENT_TIMESTAMP
(26 rows)


```
Exit code: 0

## CONSTRAINTS
```sql
SELECT conrelid::regclass AS table_name, conname, contype, pg_get_constraintdef(oid) FROM pg_constraint WHERE connamespace = 'public'::regnamespace ORDER BY 1,2;
```
```text
  table_name   |                conname                | contype |                                                                              pg_get_constraintdef                                                                               
---------------+---------------------------------------+---------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 chat_messages | chat_messages_message_id_not_null     | n       | NOT NULL message_id
 chat_messages | chat_messages_message_text_not_null   | n       | NOT NULL message_text
 chat_messages | chat_messages_pkey                    | p       | PRIMARY KEY (message_id)
 chat_messages | chat_messages_receiver_name_not_null  | n       | NOT NULL receiver_name
 chat_messages | chat_messages_sender_name_not_null    | n       | NOT NULL sender_name
 chat_messages | chat_messages_sent_at_not_null        | n       | NOT NULL sent_at
 sports_fields | chk_sports_fields_price               | c       | CHECK ((price_per_hour > (0)::numeric))
 sports_fields | chk_sports_fields_status              | c       | CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'INACTIVE'::character varying])::text[])))
 sports_fields | chk_sports_fields_time                | c       | CHECK ((close_time > open_time))
 sports_fields | chk_sports_fields_type                | c       | CHECK (((sport_type)::text = ANY ((ARRAY['GYM'::character varying, 'BASKETBALL'::character varying, 'SWIMMING'::character varying, 'PICKLEBALL'::character varying])::text[])))
 sports_fields | sports_fields_address_not_null        | n       | NOT NULL address
 sports_fields | sports_fields_close_time_not_null     | n       | NOT NULL close_time
 sports_fields | sports_fields_created_at_not_null     | n       | NOT NULL created_at
 sports_fields | sports_fields_field_id_not_null       | n       | NOT NULL field_id
 sports_fields | sports_fields_field_name_not_null     | n       | NOT NULL field_name
 sports_fields | sports_fields_open_time_not_null      | n       | NOT NULL open_time
 sports_fields | sports_fields_owner_id_not_null       | n       | NOT NULL owner_id
 sports_fields | sports_fields_pkey                    | p       | PRIMARY KEY (field_id)
 sports_fields | sports_fields_price_per_hour_not_null | n       | NOT NULL price_per_hour
 sports_fields | sports_fields_sport_type_not_null     | n       | NOT NULL sport_type
 sports_fields | sports_fields_status_not_null         | n       | NOT NULL status
 sports_fields | sports_fields_updated_at_not_null     | n       | NOT NULL updated_at
 sports_fields | uq_sports_fields_owner_name_address   | u       | UNIQUE (owner_id, field_name, address)
 reviews       | ck_reviews_rating                     | c       | CHECK (((rating >= 1) AND (rating <= 5)))
 reviews       | fk_reviews_field                      | f       | FOREIGN KEY (field_id) REFERENCES sports_fields(field_id)
 reviews       | reviews_comment_not_null              | n       | NOT NULL comment
 reviews       | reviews_created_at_not_null           | n       | NOT NULL created_at
 reviews       | reviews_customer_name_not_null        | n       | NOT NULL customer_name
 reviews       | reviews_field_id_not_null             | n       | NOT NULL field_id
 reviews       | reviews_pkey                          | p       | PRIMARY KEY (review_id)
 reviews       | reviews_rating_not_null               | n       | NOT NULL rating
 reviews       | reviews_review_id_not_null            | n       | NOT NULL review_id
(32 rows)


```
Exit code: 0

## COUNTS
```sql
SELECT 'sports_fields' AS table_name, count(*) FROM sports_fields UNION ALL SELECT 'chat_messages',count(*) FROM chat_messages UNION ALL SELECT 'reviews',count(*) FROM reviews;
```
```text
  table_name   | count 
---------------+-------
 sports_fields |     6
 chat_messages |     7
 reviews       |     5
(3 rows)


```
Exit code: 0

## OWNER_DISTRIBUTION
```sql
SELECT owner_id, count(*) AS fields FROM sports_fields GROUP BY owner_id ORDER BY owner_id;
```
```text
 owner_id | fields 
----------+--------
        1 |      6
(1 row)


```
Exit code: 0

## REVIEW_SUMMARY
```sql
SELECT f.owner_id, count(r.review_id), avg(r.rating), count(r.owner_reply) AS replied FROM sports_fields f LEFT JOIN reviews r ON r.field_id=f.field_id GROUP BY f.owner_id ORDER BY f.owner_id;
```
```text
 owner_id | count |        avg         | replied 
----------+-------+--------------------+---------
        1 |     5 | 3.0000000000000000 |       3
(1 row)


```
Exit code: 0
