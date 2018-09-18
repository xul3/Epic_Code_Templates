
--Epic continuously merge pt id, so this codes deal with that situation.

IF OBJECT_ID('TEMPDB..#BIOBANK_BASE') IS NOT NULL DROP TABLE #BIOBANK_BASE;
SELECT DISTINCT 
       CASE WHEN B.PAT_ID IS NULL THEN A.PAT_ID 
	   ELSE B.PAT_ID 
	   END AS PAT_ID  
	   ,A.PAT_ID AS OLD_PAT_ID
INTO #BIOBANK_BASE
FROM DCPWDBS149.RDD_MRT.DBO.RDD_ENC_CSN A 
     LEFT JOIN DCPWDBS149.Clarity_Rpt_Crystal.dbo.PAT_MERGE_HISTORY B ON A.PAT_ID=B.PATIENT_MRG_HIST
WHERE A.PROJECT_ID='AE_BIOBANK_MODEL' 


--alternatives methods
Method1:
SELECT DISTINCT CASE WHEN B.PAT_ID IS NULL THEN A.PAT_ID ELSE B.PAT_ID END AS PAT_ID ,
A.PAT_ID AS OLD_PAT_ID
FROM DCPWDBS149.RDD_MRT.DBO.RDD_ENC_CSN A LEFT JOIN DCPWDBS149.Clarity_Rpt_Crystal.dbo.PAT_MERGE_HISTORY B ON A.PAT_ID=B.PATIENT_MRG_HIST
            

Method2:
select distinct pat_id, pat_id as old_pat_id into #az_pcp_pats 
from dcpwdbs149.rdd_mrt.dbo.RDD_ENC_CSN
where PROJECT_ID='SM_AZ_PCP'

select distinct a.pat_id as old_pat_id, b.pat_id as new_pat_id 
into #pat_v2
from #az_pcp_pats a, dcpwdbs149.clarity_rpt_crystal.dbo.pat_merge_history b
where a.pat_id=b.patient_mrg_hist

select * into #pat_list_FINAL from 
(select * from #az_pcp_pats where pat_id not in (select old_pat_id from #pat_v2)
union 
select distinct new_pat_id as pat_id, old_pat_id from #pat_v2) as a
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

insert into RDD_ENC_CSN (pat_id, PAT_ENC_CSN_ID, PROJECT_DATE, PROJECT_ID)
select  pat_id,pat_enc_csn_id, 'upload date', 'your unique project id' as project_id from 'Your_Table_name'

insert into RDD_HSP_ACCT (pat_id, HSP_ACCOUNT_ID, PROJECT_DATE, PROJECT_ID)
select  pat_id,hsp_account_id, 'upload date', 'your unique project id' as project_id from 'Your_Table_name'
---------------------------------------------------------------------------------------------------------------
--------------EFECTIVELY FIND SERVICE AREA IDS AND ADDRESS FROM ENCOUNTER-------------------------------------- 
CLARITY_DEP           AS DEP       ON ENC.DEPARTMENT_ID=DEP.DEPARTMENT_ID
CLARITY_LOC           AS LOC       ON LOC.LOC_ID=DEP.REV_LOC_ID              --!!!!!!!! HOW TO FIND SERV ID
CLARITY_SA            AS SA        ON SA.SERV_AREA_ID=LOC.SERV_AREA_ID       --!!!!!!!!!
CLARITY_DEP_2         AS DEP2      ON DEP.DEPARTMENT_ID=DEP2.DEPARTMENT_ID
CLARITY_DEP_ADDR      AS ADDR      ON DEP2.DEPARTMENT_ID=ADDR.DEPARTMENT_ID
-----------------------------------------------------------------------------------------------------------------
--2016/12/22
--check which table most recently updated
SELECT name, [modify_date] FROM sys.tables
order by modify_date desc


insert into RDD_ENC_CSN (pat_id, PAT_ENC_CSN_ID, PROJECT_DATE, PROJECT_ID)
select  pat_id,pat_enc_csn_id, 'upload date', 'your unique project id' as project_id from 'Your_Table_name'

insert into RDD_HSP_ACCT (pat_id, HSP_ACCOUNT_ID, PROJECT_DATE, PROJECT_ID)
select  pat_id,hsp_account_id, 'upload date', 'your unique project id' as project_id from 'Your_Table_name'

RTRIM(LTRIM(STR(A.PAT_ID, 18))) AS PAT_ID, 
	CASE 
		WHEN ISNUMERIC(A.PAT_ENC_CSN_ID)=1 THEN CONVERT(NUMERIC(18,0),A.PAT_ENC_CSN_ID) 
	END AS PAT_ENC_CSN_ID 
-----------------------------------------------------------------------------------------------------------------
--2017/06/13
--SQL: how to exclude weekends Reference: https://stackoverflow.com/questions/1803987/how-do-i-exclude-weekend-days-in-a-sql-server-query
WHERE DATENAME(WEEKDAY, contact_date) <> 'Saturday' and DATENAME(WEEKDAY, contact_date) <> 'Sunday'
WHERE ((DATEPART(dw, contact_date) + @@DATEFIRST) % 7) NOT IN (0, 1) 
cast( GETDATE() as date) --get today's date
(CONVERT(VARCHAR(8), APPT.APPT_DTTM, 108) >='09:00:00' and CONVERT(VARCHAR(8), APPT.APPT_DTTM, 108)<='17:00:00') --Office hours	 
