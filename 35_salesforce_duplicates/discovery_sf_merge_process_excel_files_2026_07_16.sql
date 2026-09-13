-- =====================================================================
--  MERGE DOSSIER — EXTRACT COMMANDS
--  Extracted files are written to your Downloads folder:  C:\Users\calla\Downloads
--  (the Node command below resolves "<home>\Downloads" automatically)
-- =====================================================================

-- ---------------------------------------------------------------------
-- [1] LIST DOSSIERS  —  find the id / filename of the dossier you want
-- ---------------------------------------------------------------------
SELECT id, action, survivor_name, survivor_account, filename,
       content_document_id, byte_size, created_at_mtn
FROM salesforce_merge_dossier
ORDER BY id DESC;

-- ---------------------------------------------------------------------
-- [2] LINK DOSSIER <-> HISTORY / ACCOUNT
--     which history row + which account each dossier belongs to
-- ---------------------------------------------------------------------
SELECT h.id AS history_id, h.result, h.survivor_account, h.dossier_id, h.dossier_doc_id,
       d.action, d.filename, d.content_document_id, d.attached_to
FROM salesforce_merge_history h
JOIN salesforce_merge_dossier d ON d.id = h.dossier_id
ORDER BY h.id DESC;

-- ---------------------------------------------------------------------
-- [3] EXTRACT THE .XLSX  —  server-side dump (needs FILE priv)
--     DUMPFILE can ONLY write inside MySQL's @@secure_file_priv folder,
--     so it lands there first; then move it to Downloads.
--     Check the allowed folder first:   SELECT @@secure_file_priv;
-- ---------------------------------------------------------------------
SELECT workbook FROM salesforce_merge_dossier;

SELECT workbook INTO DUMPFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/data/dossier.xlsx'
FROM salesforce_merge_dossier WHERE id = 6;
--   then, in a shell, move it to Downloads:
--   move "C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\dossier.xlsx" "C:\Users\calla\Downloads\"
--
--   NOTE: INTO DUMPFILE writes on the MySQL *server* and only inside @@secure_file_priv,
--   so it normally CANNOT target your Downloads folder. Use [3b] or [4] for that.

-- ---------------------------------------------------------------------
-- [3b] EXTRACT STRAIGHT TO DOWNLOADS  —  mysql CLI (client-side redirect)
--      Runs on THIS machine, so it can write anywhere your shell can.
--      --raw keeps the bytes intact; -N drops the header row.
--      Run in cmd/PowerShell (not inside a SQL editor):
-- ---------------------------------------------------------------------
--   mysql -u <user> -p <db> --raw -N -e "SELECT workbook FROM salesforce_merge_dossier WHERE id=123" > "C:\Users\calla\Downloads\dossier.xlsx"
--   (if Excel complains about the file, the Node method [4] is byte-exact.)

-- ---------------------------------------------------------------------
-- [4] EXTRACT THE .XLSX  —  Node one-liner (EASIEST; no FILE priv)
--     Writes straight to Downloads using the dossier's REAL filename.
--     Run from the repo root; set id = the dossier id from query [1].
-- ---------------------------------------------------------------------
-- node -e "const{query}=require('./src/usat_apps/store/db');const fs=require('fs');const path=require('path');const os=require('os');(async()=>{const id=123;const r=await query('SELECT filename,workbook FROM salesforce_merge_dossier WHERE id=?',[id]);if(!r[0]){console.log('no dossier id',id);process.exit(1)}const out=path.join(os.homedir(),'Downloads',r[0].filename);fs.writeFileSync(out,r[0].workbook);console.log('wrote',out);process.exit(0)})()"

-- ---------------------------------------------------------------------
-- [5] DOWNLOAD VIA THE APP  —  no SQL at all
--     Streams the .xlsx with its real filename (lands in Downloads).
--     This is what the History page's paperclip link uses.
-- ---------------------------------------------------------------------
--   GET /api/salesforce-merge/merge/dossier/<id>/download

-- ---------------------------------------------------------------------
-- [6] FIND THE FILE IN SALESFORCE  —  SOQL (run in Dev Console / Workbench)
--     By the record it's attached to (survivor account):
-- ---------------------------------------------------------------------
--   SELECT ContentDocument.Title, ContentDocument.LatestPublishedVersionId, LinkedEntityId
--   FROM ContentDocumentLink WHERE LinkedEntityId = '<survivor_account_id>'
--     ...or by the exact file name:
--   SELECT Id, Title, FileExtension, ContentSize, CreatedDate
--   FROM ContentVersion WHERE Title = '<filename from query [1]>' ORDER BY CreatedDate DESC