----1a
WITH text_string AS (
  SELECT 'Spalio 11 dieną įvyko susitikimas 11:15, tuskulėnų g. 33c verslo centre.' AS text FROM dual
)
SELECT SUM( TO_NUMBER( REGEXP_SUBSTR( text, '\d+', 1, LEVEL ) ) ) AS total
FROM   text_string
CONNECT BY LEVEL <= REGEXP_COUNT( text, '\d+' )


----1b
CREATE OR REPLACE FUNCTION f_numbers_extract (l_text VARCHAR2) RETURN NUMBER IS

l_number NUMBER;

BEGIN

  SELECT SUM( TO_NUMBER( REGEXP_SUBSTR( l_text, '\d+', 1, LEVEL ) ) ) AS total
  INTO l_number
  FROM   dual
  CONNECT BY LEVEL <= REGEXP_COUNT( l_text, '\d+' );

RETURN l_number;

END;


---3

DECLARE
  l_word VARCHAR2(100) := 'TEST';
   TYPE text_record IS RECORD
   (
      table_name    VARCHAR2 (50),
      column_name   VARCHAR2 (50),
      row_id        ROWID
   );
  TYPE text_table IS TABLE OF text_record;
  
  l_answer   text_table;
  
BEGIN
  
 l_answer := text_table();
 
  FOR t IN (SELECT owner,table_name FROM dba_tables) LOOP
    FOR c IN (SELECT column_name FROM dba_tab_columns WHERE table_name = t.table_name and owner = t.owner AND data_type = 'VARCHAR2') LOOP
      EXECUTE IMMEDIATE 'SELECT ''' || t.table_name || ''',''' || c.column_name || ''',' || ' ROWID FROM ' || t.owner || '.' || t.table_name ||  ' WHERE ' || c.column_name || ' = ''' 
      || l_word || '''' BULK COLLECT INTO l_answer;
      FOR i IN 1..l_answer.count LOOP 
        dbms_output.put_line(l_answer(i).table_name || ' ' || l_answer(i).column_name || ' ' || l_answer(i).row_id);
       END LOOP;
      END LOOP;
  END LOOP;
END;

