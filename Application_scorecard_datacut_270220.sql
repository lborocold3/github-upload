-- first a litte housekeeping job - set up a table for looking up reason codes... 


drop table DIM_SRCC_POLICYRULE purge;
select * from DIM_SRCC_POLICYRULE;
CREATE TABLE DIM_SRCC_POLICYRULE AS
select distinct code ,text from AE_HDS.HDS_T_ICE1_CRDCHK_POLICYRULE a
where from_date >= to_daTE('01012016','ddmmyyyy')   
;
select * from srcc_replacement;

drop table srcc_replacement purge;
create table srcc_replacement as 
select      distinct rq.entity_id,
            f.ice_customer_id,
            rq.request_id,
            rq.request_type_id,
            trunc(rq.request_date)      request_date,
            rq.request_date             request_date_time,
            rq.user_id                  request_user_id,
            nvl(ccrq.consent_flag,ccrqs.consent_flag) as consent_flag,
            rs.response_id,
            trunc(rs.response_date)     response_date,
            rs.response_date            response_date_time,
            rs.user_id                  response_user_id,
            nvl(ccrs.bureau_urn,ccrsme.bureau_urn) as ice_bureau_urn,
            CASE WHEN nvl(ccrs.bureau_urn,ccrsme.bureau_urn)IS NOT NULL THEN 1 ELSE 0 END AS ice_bureau_FLAG,
  --                   nvl(orsd.amend_user,frsd.amend_user) as              eq_user,
  --                  nvl(orsd.app_rsn_text,frsd.app_rsn_text) as           original_eq_decision,
  --                   nvl(orsd.amend_tstamp,frsd.amend_tstamp) as           original_eq_date_time,
            nvl(nvl(ccrs.bureau_id,ccrsme.bureau_id),-1)      bureau_id,

            nvl(nvl(ccrs.check_type_id,ccrsme.check_type_id),-1)  check_type_id,
            nvl(nvl(ccrs.outcome_id,ccrsme.outcome_id),-1)     outcome_id,
            nvl(nvl(ccrs.treatment_id,ccrsme.treatment_id),-1)   treatment_id,
            nvl(nvl(ccrs.option_id,ccrsme.option_id),-1)      option_id, 
             j.check_type,
                     k.outcome AS outcome_desc,
                     option_description,
                     NVL (y1.description, y2.description)
                         AS treatment_description,
         x.description as check_sector-- ,
       --             frsd.POL_RSN   , 
      --   DPR.text AS FINAL_POLICY_TXT,
      --   new_pol.CODE as new_pol_rsn,
      --new_pol.TEXT as new_pol_txt,
       --             NVL(frsd.eqfx_ref_no, orsd.eqfx_ref_no) AS AZ_BUREAU_REF 
   --                  CASE WHEN NVL(frsd.eqfx_ref_no, orsd.eqfx_ref_no) IS NOT NULL THEN 1 ELSE 0 END AS az_BUREAU_flag 
         


from       
            AE_HDS.HDS_T_ICE2_CC_REQUEST rq 
            -- move to HDS tested 28.3.2017, ICE 2 an 1 identical
            
            left outer join AE_HDS.HDS_T_ICE1_RES_CC_REQUEST     ccrq 
            on ccrq.request_id = rq.request_id
            and nvl(ccrq.to_date,trunc(sysdate)+1) > trunc(sysdate)
            
            left outer join  AE_HDS.HDS_T_ICE1_SME_CC_REQUEST     ccrqs 
            on ccrqs.request_id = rq.request_id
            and nvl(ccrqs.to_date,trunc(sysdate)+1) > trunc(sysdate)
                        
            left outer join  AE_HDS.HDS_T_ICE1_CC_RESPONSE        rs 
            on  rs.request_id = rq.request_id
               and   nvl(rs.to_date,trunc(sysdate)+1) > trunc(sysdate)
            
            left outer join  AE_HDS.HDS_T_ICE1_RES_CC_RESPONSE    ccrs
            on  ccrs.response_id= rs.response_id
               and   nvl(ccrs.to_date,trunc(sysdate)+1) > trunc(sysdate)
 
            left outer join   AE_HDS.HDS_T_ICE1_SME_CC_RESPONSE    ccrsme
            on  ccrsme.response_id= rs.response_id
               and   nvl(ccrsme.to_date,trunc(sysdate)+1) > trunc(sysdate)
           
        --    left outer join AE_CF_MI.T_AZ_EQFX_SME_DATA orsd
        --    on orsd.eqfx_ref_no = ccrsME.bureau_urn
        --    
        --    left outer join AE_CF_MI.T_AZ_EQFX_RES_DATA frsd
        --    on frsd.eqfx_ref_no = ccrs.bureau_urn
            
            left outer join AE_HDS.HDS_T_ICE1_ENTITY_RELATIONSHIP f
           ON rq.entity_id = f.entity_id
           -- below changed to request data from sysdate to stop old ice's coming through
           -- not always right for every use of this script
           and  trunc(sysdate) between f.from_date and nvl(f.to_date,trunc(sysdate)+1)
           and  rq.request_date - trunc(start_date) <= 7
           
           AND uPPER (f.role_relationship_to) LIKE '%CUSTOMER%'
            
           -- then the In English look ups...
             LEFT OUTER JOIN ae_hds.hds_t_ice1_cc_request_type x
                         ON     rq.request_type_id = x.request_type_id
                            AND TRUNC (SYSDATE) BETWEEN x.from_date
                                                    AND NVL (
                                                            x.TO_DATE,
                                                            TRUNC (SYSDATE + 1))
                                                            
                     LEFT OUTER JOIN ae_dim.dim_v_cc_check_type j
                         ON     nvl(ccrs.check_type_id,ccrsme.check_type_id) = j.check_type_id
                            AND rq.request_type_id = j.request_type
                            AND TRUNC (SYSDATE) BETWEEN j.dw_from_date
                                                    AND NVL (
                                                            j.dw_to_date,
                                                            TRUNC (SYSDATE + 1))
                                                            
                     LEFT OUTER JOIN ae_dim.dim_v_cc_outcome k
                         ON     rq.request_type_id = k.request_type
                            AND nvl(ccrs.outcome_id,ccrsme.outcome_id) = k.outcome_id
                            AND TRUNC (SYSDATE) BETWEEN k.dw_from_date
                                                    AND NVL (
                                                            k.dw_to_date,
                                                            TRUNC (SYSDATE + 1))
                                                            
                     LEFT OUTER JOIN ae_dim.dim_v_cc_option g
                         ON     nvl(ccrs.option_id,ccrsme.option_id) = g.option_id
                            AND TRUNC (SYSDATE) BETWEEN g.dw_from_date
                                                    AND NVL (
                                                            g.dw_to_date,
                                                            TRUNC (SYSDATE + 1))
                                                            
                     LEFT OUTER JOIN ae_hds.hds_t_ice1_res_cc_treatment y1
                         ON     nvl(ccrs.treatment_id,ccrsme.treatment_id) = y1.treatment_id
                            AND UPPER (x.description) LIKE '%RESIDENTIAL%'
                            AND TRUNC (SYSDATE) BETWEEN y1.from_date
                                                    AND NVL (
                                                            y1.TO_DATE,
                                                            TRUNC (SYSDATE + 1))
                                                            
                            
                     LEFT OUTER JOIN ae_hds.hds_t_ice1_sme_cc_treatment y2
                         ON     nvl(ccrs.treatment_id,ccrsme.treatment_id) = y2.treatment_id
                            AND UPPER (x.description) LIKE '%SME%'
                            AND TRUNC (SYSDATE) BETWEEN y2.from_date
                                                    AND NVL (
                                                            y2.TO_DATE,
                                                            TRUNC (SYSDATE + 1))
              --       LEFT OUTER JOIN DIM_SRCC_POLICYRULE DPR
              --       ON frsd.POL_RSN = DPR.CODE
                     
               --      left outer join AE_HDS.HDS_T_ICE1_CRDCHK_POLICYRULE new_pol
               --      on ccrs.bureau_urn = new_pol.EQFX_REF_NO
               --      and nvl(new_pol.TO_DATE,trunc(sysdate+1)) > trunc(sysdate)
                     
                     
           
   where    rq.request_type_id in (1,2)
      
    and rq.request_date >= to_date('01032017','ddmmyyyy')   

   and      nvl(rq.to_date,trunc(sysdate)+1)   > trunc(sysdate);
   
   
    select count(*) from srcc_replacement where check_sector!='Residential Request';  --450,309
   select count(distinct ice_bureau_urn) from srcc_replacement where check_sector='Residential Request';
   select count(distinct ice_bureau_urn) from app_score_mon_5 where 
   check_sector='Residential Request'
   and treatment_id=1;
   
   select count(distinct ice_bureau_urn) from srcc_replacement where check_sector!='Residential Request'; --450309 sme --1773553--RES
   
   select count(*) from srcc_replacement where treatment_description like 'Dec%' and check_sector!='Residential Request' ;

   with base as(
select t.*,
row_number() over (partition by t.ice_bureau_urn order by request_date_time asc) as rn,
case when b.id like 'EN%' then 
b.score ELSE NULL END ENOLF_SCORE,
b.created_batch_run_date as ENOLF_DATE
from srcc_replacement_2 t
left join AE_HDS.HDS_T_ICE1_CRDCHK_SCORE b on t.ice_bureau_urn=b.eqfx_ref_no 
where id like 'E%' and b.created_batch_run_date < t.request_date_time + 10)
select b.* from base b where rn!=1;

select * from AE_HDS.HDS_T_ICE1_CRDCHK_SCORE b where b.eqfx_ref_no= '123F8822QA1K';
     
   select * from srcc_replacement_2 where ice_bureau_urn= '123F8822QA1K';
   
   --plan to take the most recent credit check and the max score? 
   ---------------------------------------------------------------------------------------------------------------------------------------
   -- MAIN -------------------------------------------------------------------------------------------------------------------------------
   ---------------------------------------------------------------------------------------------------------------------------------------
   
   select * from AE_HDS.HDS_T_ICE1_CRDCHK_SCORE b;
   
   select * from srcc_replacement_2 where entity_id =2248571;
   
   select count(*) from srcc_replacement_2;
  select count(*) from srcc_replacement_2 where check_sector!='Residential Request';
   drop table srcc_replacement_2 purge;
CREATE TABLE srcc_replacement_2  Compress Pctfree 0 Parallel 16 AS
select v.entity_id,
       max(v.ice_customer_id) as ice_customer_id_max,
       count(v.ice_customer_id) as ice_id_count, 
       v.request_id,
       v.request_type_id,
       v.request_date_time,
       v.request_user_id,
       v.consent_flag,
       v.response_id,
       v.response_date,
       v.response_date_time,
       v.response_user_id,
       v.ice_bureau_urn,
       v.ice_bureau_flag,
       v.bureau_id,
       v.check_type_id,
       v.outcome_id,
       v.treatment_id,
       v.option_id,
       v.check_type,
       v.outcome_desc,
       v.option_description,
       v.treatment_description,
       v.check_sector from srcc_replacement v where ice_bureau_urn is not null
       group by 
       v.request_id,
       v.request_type_id,
       v.request_date,
       v.request_date_time,
       v.request_user_id,
       v.consent_flag,
       v.response_id,
       v.response_date,
       v.response_date_time,
       v.response_user_id,
       v.ice_bureau_urn,
       v.ice_bureau_flag,
       v.bureau_id,
       v.check_type_id,
       v.outcome_id,
       v.treatment_id,
       v.option_id,
       v.check_type,
       v.outcome_desc,
       v.option_description,
       v.treatment_description,
       v.check_sector,
       v.entity_id;
       
select * from srcc_replacement; 
select count(*) from srcc_replacement where ice_bureau_urn is null;
select count(*) from srcc_replacement_2; --1489839
select count(distinct t.ice_bureau_urn) from srcc_replacement_2 t; --1468932 distinct ICE BUREAU URN --2000 records are duplicates


--choose the max request date only

drop table srcc_replacement_2_int purge;
CREATE TABLE srcc_replacement_2_int  Compress Pctfree 0 Parallel 16 AS
with base as (select 
       v.entity_id,
       v.ice_customer_id_max,
       row_number() over (partition by ice_bureau_urn order by v.ice_customer_id_max asc nulls last) as rn,
       v.ice_bureau_urn
       from srcc_replacement_2 v group by 
       v.entity_id,
       v.ice_customer_id_max,
       v.ice_bureau_urn)
       select 
       l.entity_id,
       l.ice_customer_id_max,
       l.ice_bureau_urn
       from base l where rn=1;

select count(*) from srcc_replacement_2_int;  --1468932
select count(distinct ice_bureau_urn) from srcc_replacement_2_int; --1848919 -- unique ice urn 1468932
select count(*) from srcc_replacement_2_int;


select * from srcc_replacement_2_int where ice_bureau_urn = '123F3S9A9J1U';
select * from srcc_replacement_2 where ice_bureau_urn = '123F47N0J6P5';


--append back all info
drop table srcc_replacement_2_int2 purge;
CREATE TABLE srcc_replacement_2_int2  Compress Pctfree 0 Parallel 16 AS
select y.entity_id,
       y.ice_customer_id_max,
       y.ice_bureau_urn,
       i.request_id,
       i.request_type_id,
       i.consent_flag,
       i.ice_bureau_flag,
       i.bureau_id,
       i.check_type_id,
       i.outcome_id,
       i.treatment_id,
       i.option_id,
       i.check_type,
       i.outcome_desc,
       i.option_description,
       i.treatment_description,
       i.check_sector 
        from
srcc_replacement_2_int y
left join srcc_replacement_2 i on y.entity_id= i.entity_id 
and y.ice_bureau_urn= i.ice_bureau_urn; 


select count(*) from srcc_replacement_2_int2; --1489839
select count(distinct ice_bureau_urn) from srcc_replacement_2_int2; --1468932

with base as (
select u.*,
row_number() over (partition by ice_bureau_urn order by u.ice_customer_id_max asc) as rn 
from srcc_replacement_2_int2 u)
select * from base where rn!=1;

select count(*) from  srcc_replacement_2_int2; --1489839


select * from srcc_replacement_2_int2 where ice_bureau_urn='123F3WN2M0K1';

drop table srcc_replacement_3 purge;
CREATE TABLE srcc_replacement_3  Compress Pctfree 0 Parallel 16 AS
with base as (
select t.*,
case when b.id like 'EN%' then 
b.score ELSE NULL END ENOLF_SCORE,
b.created_batch_run_date as ENOLF_DATE
from srcc_replacement_2 t
left join AE_HDS.HDS_T_ICE1_CRDCHK_SCORE b on t.ice_bureau_urn=b.eqfx_ref_no 
where id like 'E%' 
and b.created_batch_run_date < t.request_date_time + 7
order by entity_id )
, base2 as 
(
select h.*,
row_number() over (partition by h.ice_bureau_urn, h.request_id order by h.ENOLF_DATE desc) as rn
 from base h
)
select * from base2 where rn=1;

;
select count(distinct ice_bureau_urn) from srcc_replacement_3 where ENOLF_SCORE is NULL;  --unique URN 1220896 -- total 1233093
select count(*) from srcc_replacement_3; --1244190 --all distinct ICE bureau urn 

  select count(*) from srcc_replacement_4 where check_sector!='Residential Request';

drop table srcc_replacement_4 purge;
CREATE TABLE srcc_replacement_4  Compress Pctfree 0 Parallel 16 AS
with base as (
select t.entity_id,
       t.ice_customer_id_max,
       t.ice_id_count,
       t.request_id,
       t.request_type_id,
       t.request_date_time,
       t.request_user_id,
       t.consent_flag,
       t.response_id,
       t.response_date,
       t.response_date_time,
       t.response_user_id,
       t.ice_bureau_urn,
       t.ice_bureau_flag,
       t.bureau_id,
       t.check_type_id,
       t.outcome_id,
       t.treatment_id,
       t.option_id,
       t.check_type,
       t.outcome_desc,
       t.option_description,
       t.treatment_description,
       t.check_sector,
       t.enolf_score,
       t.enolf_date,
case when b.id like 'RNOL%' then 
b.score ELSE NULL END RNOLF_SCORE,
b.created_batch_run_date as RNOLF_DATE
from srcc_replacement_3 t
left join AE_HDS.HDS_T_ICE1_CRDCHK_SCORE b on t.ice_bureau_urn=b.eqfx_ref_no 
where id like 'R%' 
and b.created_batch_run_date < t.request_date_time + 7
order by entity_id )
, base2 as 
(
select h.*,
row_number() over (partition by h.ice_bureau_urn, h.request_id order by h.RNOLF_DATE desc) as rn
 from base h
)
select * from base2 where rn=1;
;



select count(distinct ice_bureau_urn) from srcc_replacement_4 where RNOLF_DATE> ENOLF_DATE + 12; --total 1233074 --total unique URN --Leng: 54
select count(*) from srcc_replacement_4; --1244173 --Leng:1452444

select * from srcc_replacement_4;

--need to append the information from the select * from AE_HDS.Hds_t_Ice1_Res_Cc_Response_Det table;  


drop table srcc_replacement_5 purge;
CREATE TABLE srcc_replacement_5  Compress Pctfree 0 Parallel 16 AS
with base as(
select j.*,
k.app_rsn,
k.app_rsn_text,
k.created_batch_run_date,
row_number() over (partition by k.bureau_urn order by k.created_batch_run_date desc) as rn2
 from srcc_replacement_4 j
left join
AE_HDS.Hds_t_Ice1_Res_Cc_Response_Det k on
j.ice_bureau_urn=k.bureau_urn)
select * from base t where t.rn2=1

;
select count(distinct h.ice_bureau_urn) from srcc_replacement_5 h; --Leng: 1437704
select * from a32616.rpt_1067_srcc_replacement ;--Leng: ???



select count(*) from a32616.rpt_1067_srcc_replacement where request_date 
between to_date('01072019','ddmmyyyy') and to_date('31072019','ddmmyyyy')
  and  check_sector='Residential Request';--Leng: ???

select j.*, ntile(10) over (partition by  from srcc_replacement_5 j where j.ice_bureau_urn ='123HC63J95KF';--Leng: ???

select count(*) from srcc_replacement_5;--Leng:1437704
select * from srcc_replacement_5 j where check_sector not like 'Res%'; --Leng: Empty

select count(*) from srcc_replacement_5 where request_date_time 
between to_date('01072019','ddmmyyyy') and to_date('31072019','ddmmyyyy')
  and  check_sector='Residential Request'; --Leng:53144
--total -53229 --with terms 6836 -12%
and app_rsn_text!='All Payment Methods'--Leng:?
select count(*) from srcc_replacement_2 u where u.ice_bureau_urn not in (select ice_bureau_urn from srcc_replacement_4); --233120 --Leng:507621

with base as (
select j.*, ntile(10) over (partition by (numtoyminterval(1, 'MONTH')) order by j.enolf_score) as deciles
 from srcc_replacement_5 j )
select count(deciles) from base where deciles=3 and 
request_date_time between  to_date('01072019','ddmmyyyy') and to_date('31072019','ddmmyyyy');--Leng: 4967



-- ignore here onwards --Leng: ignore then where to restart?

drop table srcc_replacement_ddi purge;
create table srcc_replacement_ddi as
select b.ice_customer_id
from AE_BDM.BDM_V_PENDING_DDI_OK a
inner join srcc_replacement b
on a.ice_customer_id = b.ice_customer_id
and b.request_date between a.dw_from_date and a.dw_to_date;

drop table srcc_replacement_new_sc purge;
create table srcc_replacement_new_sc as
select * from AE_HDS.HDS_T_ICE1_CRDCHK_SCORE b
where eqfx_ref_no||id||trunc(loaded_date)||score in 
(select a.eqfx_ref_no||a.id||max(trunc(a.loaded_date)||a.score) as linker
from AE_HDS.HDS_T_ICE1_CRDCHK_SCORE a

-- problems with from dates being filled in!
where trunc(loaded_date) >= '01-Jan-2017'
group by a.eqfx_ref_no, a.id);
   
   
   select * from AE_HDS.HDS_T_ICE1_CRDCHK_SCORE where EQFX_REF_NO like '123F8U6JEBQE';
   select * from AE_BDM.BDM_V_PENDING_DDI_OK;
   select * from ae_dim.dim_v_cc_check_type ;
   select * from ae_hds.hds_t_ice1_res_cc_treatment;
   select * from AE_HDS.HDS_T_ICE1_RES_CC_RESPONSE ;
   
  select * from AE_HDS.HDS_T_ICE1_RES_CC_REQUEST;  
   
  select * from  hds_t_ice1_sme_cc_response;

select * from             hds_t_ice1_sme_cc_resp_det srd;
select * from  hds_t_ice1_crdchk_rnscore s where score_label like 'EN%';
select * from hds_t_ice1_crdchk_score where ID like 'EN%';
select * from              hds_t_ice1_cc_response res;
select * from              hds_t_ice1_cc_request req;
   
select * from AE_HDS.HDS_T_ICE1_CRDCHK_SCORE a where a.eqfx_ref_no in
('123FAMK4FKYN',
'323FAMN77VYZ',
'123FAMK0KGAQ');



   select count(DISTINCT A.ice_customer_id) as vol, 
max(a.ice_customer_id) as sample_ice_id_1, 
min(a.ice_customer_id) as sample_ice_id_2,
max(a.ice_bureau_urn), 
case    when upper(a.request_user_id) like '%SYSTEM%' then 'SYSTEM'
        when upper(a.request_user_id) is not null then 'Not SYSTEM'
        else 'null' end as request_user_group,
case when REQUEST_DATE <= '30-Apr-2017' then to_char(REQUEST_DATE,'yyyymm') else to_char(REQUEST_DATE,'yyyymmdd') end as request_date, 
--FINAL_POLICY_TXT,
OPTION_DESCRIPTION,
TREATMENT_DESCRIPTION,
-- ORIGINAL_EQ_DECISION, 
a.consent_flag, 
a.ice_bureau_flag,
--a.az_bureau_flag, 
a.check_type, 
a.CHECK_SECTOR, 

b.id as eq_score_id, 
-- 1*b.score as eq_score, 
0 as eq_score,

c.id as eon_score_id,
-- 1*c.score as eon_score,
 0 as eon_score,
case when dd.ice_customer_id is not null then 1 else 0 end as ddi_flag



from srcc_replacement a 

left outer join srcc_replacement_new_sc b
on a.ice_bureau_urn = b.eqfx_ref_no
and b.id like '%RNO%'

left outer join srcc_replacement_new_sc c
on a.ice_bureau_urn = c.eqfx_ref_no
and c.id not like '%RNO%'

left outer join srcc_replacement_ddi dd
on a.ice_customer_id = dd.ice_customer_id

where 1=1
-- upper(a.check_type) like '%EXTERNAL%'

and upper(CHECK_SECTOR) like '%RES%' 
group by case when REQUEST_DATE <= '30-Apr-2017' then to_char(REQUEST_DATE,'yyyymm') else to_char(REQUEST_DATE,'yyyymmdd') end, 
--FINAL_POLICY_TXT,
OPTION_DESCRIPTION,
TREATMENT_DESCRIPTION,
-- ORIGINAL_EQ_DECISION, 
a.consent_flag, 
a.ice_bureau_flag,
--a.az_bureau_flag, 
a.check_type, 
a.CHECK_SECTOR,

b.id  ,
-- 1*b.score  , 
c.id  ,
-- 1*c.score ,
case    when upper(a.request_user_id) like '%SYSTEM%' then 'SYSTEM'
        when upper(a.request_user_id) is not null then 'Not SYSTEM'
        else 'null' end, 
case when dd.ice_customer_id is not null then 1 else 0 end;



select  
i.ice_customer_id, 
i.request_id,  
trunc(i.request_date) as request_date,  
i.request_user_id,   
b.user_name,  
i.response_id,   
i.bureau_urn,   
i.request_manager_id,    
j.check_type,   
k.outcome as outcome_desc,   
option_description,   
nvl(y1.description,y2.description) as treatment_description,   
b.l5_historical_team_name,   
to_char(i.request_date,'yyyymm') as req_month,   
b.l6_historical_team_name,   
b.l7_historical_team_name,   
b.l8_historical_team_name  
from  aml_t_srcc_event_detail i  
left outer join AE_HDS.HDS_T_ICE1_CC_REQUEST_TYPE x  
on i.request_type_id = x.request_type_id  
and trunc(sysdate) between x.from_date and  nvl(x.to_date,trunc(sysdate+1))  
left outer join ae_dim.dim_v_cc_check_type j  
on i.check_type_id = j.check_type_id  
and i.request_type_id = j.request_type  
and trunc(sysdate) between j.dw_from_date and  nvl(j.dw_to_date,trunc(sysdate+1))   
left outer join ae_dim.dim_v_cc_outcome k  
on i.request_type_id = k.request_type  
and i.outcome_id = k.outcome_id  
and trunc(sysdate) between k.dw_from_date and  nvl(k.dw_to_date,trunc(sysdate+1))  
left outer join ae_dim.dim_v_cc_option g  
on  i.option_id = g.option_id  
and trunc(sysdate) between g.dw_from_date and  nvl(g.dw_to_date,trunc(sysdate+1))  
left outer join AE_HDS.HDS_T_ICE1_RES_CC_TREATMENT y1  
on i.treatment_id = y1.treatment_id  
and trunc(sysdate) between y1.from_date and  nvl(y1.to_date,trunc(sysdate+1))  
and upper(x.description) like '%RESIDENTIAL%'  
left outer join AE_HDS.HDS_T_ICE1_SME_CC_TREATMENT y2  
on i.treatment_id = y2.treatment_id  
and  trunc(sysdate) between y2.from_date and  nvl(y2.to_date,trunc(sysdate+1))  
and upper(x.description) like '%SME%'  
left outer join dim_v_oda_user_flat b  
on i.request_user_id = b.user_id  
where i.request_date >= '01-DEC-18'
;

--add fire account references
select * from hds_t_ice1_account;

drop table app_score_mon_interim purge;
CREATE TABLE app_score_mon_interim COMPRESS PCTFREE 0 PARALLEL 16 AS
select a.*, b.account_reference as financial_account_reference
from srcc_replacement_5 a left join hds_t_ice1_account b on a.ice_customer_id_max= b.ice_customer_id and b.key_type=12;

select count(*) from app_score_mon_interim; --2.25M
select count(*) from srcc_replacement_5;  --1.22M

drop table app_score_mon_1 purge;
CREATE TABLE app_score_mon_1 COMPRESS PCTFREE 0 PARALLEL 16 AS

SELECT    /*+ PARALLEL(64)*/ 
          a. entity_id,
           a.ice_customer_id_max,
           a.ice_id_count,
           a.request_id,
           a.request_type_id,
           a.request_date_time,
           a.request_user_id,
           a.consent_flag,
           a.response_id,
           a.response_date,
           a.response_date_time,
           a.response_user_id,
           a.ice_bureau_urn,
           a.ice_bureau_flag,
           a.bureau_id,
           a.check_type_id,
           a.outcome_id,
           a.treatment_id,
           a.option_id,
           a.check_type,
           a.outcome_desc,
           a.option_description,
           a.treatment_description,
           a.check_sector,
           a.enolf_score,
           a.enolf_date,
           a.rnolf_score,
           a.rnolf_date,
           a.app_rsn,
           a.app_rsn_text,
           a.created_batch_run_date,
           a.financial_account_reference,
          b.prov_account_status,
          NVL(b.cst_group_id, 'UNKNOWN') cst_group_id,
          CASE WHEN b.prov_payment_method_group IN ('VDD', 'FDD') THEN 'DD'
               WHEN b.prov_payment_method_group IN ('PREPAYMENT') THEN 'PPM'
               WHEN b.prov_payment_method_group IN ('MDB') THEN 'PPM'
               WHEN b.prov_payment_method_group IN ('PAYG') THEN 'PPM'
               ELSE 'OD' 
               END AS prov_pay_group_ifrs9,
          b.combined_liquidation,
          b.final_age, 
          b.max_age, 
          b.total_balance,
          b.analysis_date,
          ROW_NUMBER() OVER (PARTITION BY a.financial_account_reference ORDER BY b.analysis_date) prov_rn
FROM      app_score_mon_interim a,
          ae_aml.aml_t_cfab_wk_prov_data b
WHERE     a.financial_account_reference = b.financial_account_reference (+)
AND       a.request_date_time <= b.analysis_date (+)
          --get all data after the cc analysis date and choose the most recent on row number
AND       'Debit' = b.credit_debit_flag (+)
AND       b.cst_group_id (+) IN ('SME', 'RESIDENTIAL')
/

select * from app_score_mon_1;
select count(*) from app_score_mon_1; --29.8M --Leng: 39155490


--ignore for now

drop table app_score_mon_2 purge;
CREATE TABLE app_score_mon_2 COMPRESS PCTFREE 0 PARALLEL 16 AS
select a.*,
case when a.max_age >=120 and a.total_balance>=25.00 then 1 else 0 END bad_flag,
  case when a.max_age >=120 and a.total_balance>=25.00 and a.analysis_date-a.response_date<=365 then 1 else 0 END bad_flag_365
 from app_score_mon_1 a;

select count(*) from app_score_mon_2;

drop table app_score_mon_3 purge;
CREATE TABLE app_score_mon_3 COMPRESS PCTFREE 0 PARALLEL 16 AS
select a.entity_id,
       a.ice_customer_id_max,
       a.ice_id_count,
       a.request_id,
       a.request_type_id,
       a.request_date_time,
       a.request_user_id,
       a.consent_flag,
       a.response_id,
       a.response_date,
       a.response_date_time,
       a.response_user_id,
       a.ice_bureau_urn,
       a.ice_bureau_flag,
       a.bureau_id,
       a.check_type_id,
       a.outcome_id,
       a.treatment_id,
       a.option_id,
       a.check_type,
       a.outcome_desc,
       a.option_description,
       a.treatment_description,
       a.check_sector,
       a.enolf_score,
       a.enolf_date,
       a.rnolf_score,
       a.rnolf_date,
       a.app_rsn,
       a.app_rsn_text,
       a.created_batch_run_date,
       a.financial_account_reference,
max(a.bad_flag) over (partition by a.financial_account_reference order by a.analysis_date desc) as bad_flag, 
max(a.bad_flag_365) over (partition by a.financial_account_reference order by a.analysis_date desc) as bad_flag_365
from app_score_mon_2 a;

select * from app_score_mon_3;

drop table app_score_mon_4 purge;
CREATE TABLE app_score_mon_4 COMPRESS PCTFREE 0 PARALLEL 16 AS
select distinct a.entity_id,
                      a.ice_customer_id_max,
                      a.ice_id_count,
                      a.request_id,
                      a.request_type_id,
                      a.request_date_time,
                      a.request_user_id,
                      a.consent_flag,
                      a.response_id,
                      a.response_date,
                      a.response_date_time,
                      a.response_user_id,
                      a.ice_bureau_urn,
                      a.ice_bureau_flag,
                      a.bureau_id,
                      a.check_type_id,
                      a.outcome_id,
                      a.treatment_id,
                      a.option_id,
                      a.check_type,
                      a.outcome_desc,
                      a.option_description,
                      a.treatment_description,
                      a.check_sector,
                      a.enolf_score,
                      a.enolf_date,
                      a.rnolf_score,
                      a.rnolf_date,
                      a.app_rsn,
                      a.app_rsn_text,
                      a.created_batch_run_date,
                      a.financial_account_reference,
                      a.bad_flag,
                      a.bad_flag_365 from app_score_mon_3 a;

--1.38M disticnt 

drop table app_score_mon_5 purge;
CREATE TABLE app_score_mon_5 COMPRESS PCTFREE 0 PARALLEL 16 AS
select distinct b.entity_id,
                b.ice_customer_id_max,
                b.ice_id_count,
                b.request_id,
                b.request_type_id,
                b.request_date_time,
                b.request_user_id,
                b.consent_flag,
                b.response_id,
                b.response_date,
                b.response_date_time,
                b.response_user_id,
                b.ice_bureau_urn,
                b.ice_bureau_flag,
                b.bureau_id,
                b.check_type_id,
                b.outcome_id,
                b.treatment_id,
                b.option_id,
                b.check_type,
                b.outcome_desc,
                b.option_description,
                b.treatment_description,
                b.check_sector,
                b.enolf_score,
                b.enolf_date,
                b.rnolf_score,
                b.rnolf_date,
                b.app_rsn,
                b.app_rsn_text,
                b.created_batch_run_date,
                max(b.bad_flag) over (partition by b.ice_customer_id_max) as bad_flag,
                max(b.bad_flag_365) over (partition by b.ice_customer_id_max) as bad_flag_365
                from app_score_mon_4 b ;


select count(*) from app_score_mon_5; --Leng: 1437704

select count(*) from app_score_mon_5 where bad_flag_365=1 
and request_date_time between to_daTE('01072017','ddmmyyyy') 
and to_daTE('01072018','ddmmyyyy'); --1.22M --64212k  bad  (5.2%) 43224 bad 365 (3.5%) --Leng: 42669
select count(distinct ice_bureau_urn) from app_score_mon_4;--Leng: 1437704
select count(distinct d.ice_customer_id_max) from app_score_mon_4 d where bad_flag_365=1; --Leng:82891
select count(*) 

;

select * from app_score_mon_5;
select count(*) from app_score_mon_5 where 
request_date_time between to_daTE('01072017','ddmmyyyy') and to_daTE('01072018','ddmmyyyy') and bad_flag=1;

--577214 --Leng: 69870

select count(distinct entity_id) from app_score_mon_5
where 
request_date_time between to_daTE('01072017','ddmmyyyy') and to_daTE('01072018','ddmmyyyy');   --574076 app --Leng: 574083

select count(*) from app_score_mon_5 a where RPAD(a.entity_id,10,'Z')||'1'||'1'||'0000' not in (select s.urn from 
c5498.aml_t_eqfx_retro_res_final s)
;


select count(*) from app_score_mon_5 where RNOLF_SCORE between -400 and -300 and bad_flag=1; --Leng: 3


select * from app_score_mon_5;



---- SME data cut
  select count(*) from srcc_replacement where check_sector!='Residential Request'; --450309
    select * from srcc_replacement where check_sector!='Residential Request'; -- use entity id as URN 
  select count(*) from srcc_replacement_2 where check_sector!='Residential Request'; --62383
  select count(*) from srcc_replacement_2_SME;
  
  CREATE TABLE srcc_replacement_2_SME  Compress Pctfree 0 Parallel 16 AS
select  /*+ PARALLEL(64)*/  v.entity_id,
       max(v.ice_customer_id) as ice_customer_id_max,
       count(v.ice_customer_id) as ice_id_count, 
       v.request_id,
       v.request_type_id,
       v.request_date_time,
       v.request_user_id,
       v.consent_flag,
       v.response_id,
       v.response_date,
       v.response_date_time,
       v.response_user_id,
       v.ice_bureau_urn,
       v.ice_bureau_flag,
       v.bureau_id,
       v.check_type_id,
       v.outcome_id,
       v.treatment_id,
       v.option_id,
       v.check_type,
       v.outcome_desc,
       v.option_description,
       v.treatment_description,
       v.check_sector 
       from srcc_replacement v where ice_bureau_urn is not null
       group by 
       v.request_id,
       v.request_type_id,
       v.request_date,
       v.request_date_time,
       v.request_user_id,
       v.consent_flag,
       v.response_id,
       v.response_date,
       v.response_date_time,
       v.response_user_id,
       v.ice_bureau_urn,
       v.ice_bureau_flag,
       v.bureau_id,
       v.check_type_id,
       v.outcome_id,
       v.treatment_id,
       v.option_id,
       v.check_type,
       v.outcome_desc,
       v.option_description,
       v.treatment_description,
       v.check_sector,
       v.entity_id;

drop table srcc_replacement_2_SME1 purge;
CREATE TABLE srcc_replacement_2_SME1  Compress Pctfree 0 Parallel 16 AS
with base as (select  /*+ PARALLEL(64)*/ 
       v.entity_id,
       v.ice_customer_id_max,
       row_number() over (partition by entity_id order by v.ice_customer_id_max asc nulls last) as rn,
       v.ice_bureau_urn
       from srcc_replacement_2_SME v group by 
       v.entity_id,
       v.ice_customer_id_max,
       v.ice_bureau_urn)
       select 
       l.entity_id,
       l.ice_customer_id_max,
       l.ice_bureau_urn
       from base l where rn=1;



drop table srcc_replacement_2_SME2 purge;
CREATE TABLE srcc_replacement_2_SME2  Compress Pctfree 0 Parallel 16 AS
select /*+ PARALLEL(64)*/  y.entity_id,
       y.ice_customer_id_max,
       y.ice_bureau_urn,
       i.ice_id_count,
       i.request_id,
       i.request_type_id,
       i.request_date_time,
       i.request_user_id,
       i.consent_flag,
       i.response_id,
       i.response_date,
       i.response_date_time,
       i.response_user_id,
       i.ice_bureau_flag,
       i.bureau_id,
       i.check_type_id,
       i.outcome_id,
       i.treatment_id,
       i.option_id,
       i.check_type,
       i.outcome_desc,
       i.option_description,
       i.treatment_description,
       i.check_sector
        from
srcc_replacement_2_SME1 y
left join srcc_replacement_2_SME i on y.entity_id= i.entity_id 
and y.ice_bureau_urn= i.ice_bureau_urn; 

select count(*) from srcc_replacement_2_SME2 where check_sector!='Residential Request' and ice_bureau_urn is null; --57714 SME
select * from srcc_replacement_2_SME2 where check_sector!='Residential Request';

select count(distinct ice_bureau_urn)
 from srcc_replacement_2_SME2 t left join  AE_HDS.HDS_T_ICE1_CRDCHK_SCORE b on t.ice_bureau_urn=b.eqfx_ref_no where 
t.check_sector!='Residential Request' ; --33998 sme reduced from 62383 -52,223 --Leng: 63422


drop table srcc_replacement_3_SME purge;
CREATE TABLE srcc_replacement_3_SME  Compress Pctfree 0 Parallel 16 AS
with base as (
select  /*+ PARALLEL(64)*/  t.*,
case when b.id like 'EN%' then 
b.score ELSE NULL END ENOLF_SCORE,
b.created_batch_run_date as ENOLF_DATE
from srcc_replacement_2_SME2 t
left join AE_HDS.HDS_T_ICE1_CRDCHK_SCORE b on t.ice_bureau_urn=b.eqfx_ref_no 
where id like 'E%' 
and b.created_batch_run_date < t.request_date_time + 7
order by entity_id )
, base2 as 
(
select /*+ PARALLEL(64)*/  h.*,
row_number() over (partition by h.ice_bureau_urn, h.request_id order by h.ENOLF_DATE desc) as rn
 from base h
)
select  /*+ PARALLEL(64)*/ * from base2 where rn=1;


select count(*) from srcc_replacement_3_SME where check_sector!='Residential Request'; --57714 SME --Leng: 0?


drop table srcc_replacement_5_SME purge;
CREATE TABLE srcc_replacement_5_SME  Compress Pctfree 0 Parallel 16 AS
select t.entity_id,
       t.ice_customer_id_max,
       t.ice_bureau_urn,
       t.ice_id_count,
       t.request_id,
       t.request_type_id,
       t.request_date_time,
       t.request_user_id,
       t.consent_flag,
       t.response_id,
       t.response_date,
       t.response_date_time,
       t.response_user_id,
       t.ice_bureau_flag,
       t.bureau_id,
       t.check_type_id,
       t.outcome_id,
       t.treatment_id,
       t.option_id,
       t.check_type,
       t.outcome_desc,
       t.option_description,
       t.treatment_description,
       t.check_sector
 from srcc_replacement_2_SME2 t left join  AE_HDS.HDS_T_ICE1_CRDCHK_SCORE b on t.ice_bureau_urn=b.eqfx_ref_no where 
t.check_sector!='Residential Request' ; --33998 sme reduced from 62383 -52,223


drop table srcc_replacement_6_SME purge;
CREATE TABLE srcc_replacement_6_SME  Compress Pctfree 0 Parallel 16 AS
with base3 as (select y.*, 
row_number() over (partition by ice_bureau_urn order by request_date_time asc) as rn 
from srcc_replacement_5_SME y) select * from base3 where rn=1; --52223 --57933

select * from srcc_replacement_5_SME where eqfx_ref_no is not null;--Leng: No eqfx table



drop table app_score_mon_interim_SME purge;
CREATE TABLE app_score_mon_interim_SME COMPRESS PCTFREE 0 PARALLEL 16 AS
select /*+ PARALLEL(64)*/  a.*, b.account_reference as financial_account_reference
from srcc_replacement_6_SME a left join hds_t_ice1_account b on a.ice_customer_id_max= b.ice_customer_id and b.key_type=12;


drop table app_score_mon_1_SME purge;
CREATE TABLE app_score_mon_1_SME COMPRESS PCTFREE 0 PARALLEL 16 AS

SELECT    /*+ PARALLEL(64)*/ 
          a.*, --Leng: missing columns in table a
         /*a.entity_id,
         a.ice_customer_id_max,
         a.ice_bureau_urn,
         a.ice_id_count,
         a.request_id,
         a.request_type_id,
         a.request_date_time,
         a.request_user_id,
         a.consent_flag,
         a.response_id,
         a.response_date,
         a.response_date_time,
         a.response_user_id,
         a.ice_bureau_flag,
         a.bureau_id,
         a.check_type_id,
         a.outcome_id,
         a.treatment_id,
         a.option_id,
         a.check_type,
         a.outcome_desc,
         a.option_description,
         a.treatment_description,
         a.check_sector,
         a.eqfx_ref_no,
         a.type,
         a.id,
         a.text,
         a.score,
         a.person_no,
         a.from_date,
         a.to_date,
         a.created_batch_run_date,
         a.updated_batch_run_date,
         a.loaded_date,
         a.rn,
         a.financial_account_reference,*/
          b.prov_account_status,
          NVL(b.cst_group_id, 'UNKNOWN') cst_group_id,
          CASE WHEN b.prov_payment_method_group IN ('VDD', 'FDD') THEN 'DD'
               WHEN b.prov_payment_method_group IN ('PREPAYMENT') THEN 'PPM'
               WHEN b.prov_payment_method_group IN ('MDB') THEN 'PPM'
               WHEN b.prov_payment_method_group IN ('PAYG') THEN 'PPM'
               ELSE 'OD' 
               END AS prov_pay_group_ifrs9,
          b.combined_liquidation,
          b.final_age, 
          b.max_age, 
          b.total_balance,
          b.analysis_date,
          ROW_NUMBER() OVER (PARTITION BY a.financial_account_reference ORDER BY b.analysis_date) prov_rn
FROM      app_score_mon_interim_SME a,
          ae_aml.aml_t_cfab_wk_prov_data b
WHERE     a.financial_account_reference = b.financial_account_reference (+)
AND       a.request_date_time <= b.analysis_date (+)
          --get all data after the cc analysis date and choose the most recent on row number
AND       'Debit' = b.credit_debit_flag (+)
AND       b.cst_group_id (+) IN ('SME', 'RESIDENTIAL')
/

select * from app_score_mon_1_SME;
select count(*) from app_score_mon_1; --29.8M --39155490


--ignore for now

drop table app_score_mon_2_SME purge;
CREATE TABLE app_score_mon_2_SME COMPRESS PCTFREE 0 PARALLEL 16 AS
select  /*+ PARALLEL(64)*/ a.*,
case when a.max_age >=120 and a.total_balance>=25.00 then 1 else 0 END bad_flag,
  case when a.max_age >=120 and a.total_balance>=25.00 and a.analysis_date-a.response_date<=365 then 1 else 0 END bad_flag_365
 from app_score_mon_1_SME a;

select count(*) from app_score_mon_2;--Leng:39155490

drop table app_score_mon_3_SME purge;
CREATE TABLE app_score_mon_3_SME COMPRESS PCTFREE 0 PARALLEL 16 AS
select  /*+ PARALLEL(64)*/ a.entity_id,
                           a.ice_customer_id_max,
                           a.ice_bureau_urn,
                           a.ice_id_count,
                           a.request_id,
                           a.request_type_id,
                           a.request_date_time,
                           a.request_user_id,
                           a.consent_flag,
                           a.response_id,
                           a.response_date,
                           a.response_date_time,
                           a.response_user_id,
                           a.ice_bureau_flag,
                           a.bureau_id,
                           a.check_type_id,
                           a.outcome_id,
                           a.treatment_id,
                           a.option_id,
                           a.check_type,
                           a.outcome_desc,
                           a.option_description,
                           a.treatment_description,
                           a.check_sector,
                           a.rn,
                           a.financial_account_reference,
                           a.prov_account_status,
                           a.cst_group_id,
                           a.prov_pay_group_ifrs9,
                           a.combined_liquidation,
                           a.final_age,
                           a.max_age,
                           a.total_balance,
                           a.analysis_date,
                           a.prov_rn,
                           /*a.entity_id,
                           a.ice_customer_id_max,
                           a.ice_bureau_urn,
                           a.ice_id_count,
                           a.request_id,
                           a.request_type_id,
                           a.request_date_time,
                           a.request_user_id,
                           a.consent_flag,
                           a.response_id,
                           a.response_date,
                           a.response_date_time,
                           a.response_user_id,
                           a.ice_bureau_flag,
                           a.bureau_id,
                           a.check_type_id,
                           a.outcome_id,
                           a.treatment_id,
                           a.option_id,
                           a.check_type,
                           a.outcome_desc,
                           a.option_description,
                           a.treatment_description,
                           a.check_sector,
                           a.eqfx_ref_no,
                           a.type,
                           a.id,
                           a.text,
                           a.score,
                           a.person_no,
                           a.from_date,
                           a.to_date,
                           a.created_batch_run_date,
                           a.updated_batch_run_date,
                           a.loaded_date,
                           a.rn,
                           a.financial_account_reference,
                           a.prov_account_status,
                           a.cst_group_id,
                           a.prov_pay_group_ifrs9,
                           a.combined_liquidation,
                           a.final_age,
                           a.max_age,
                           a.total_balance,
                           a.analysis_date,
                           a.prov_rn,
                           */
max(a.bad_flag) over (partition by a.financial_account_reference order by a.analysis_date desc) as bad_flag, 
max(a.bad_flag_365) over (partition by a.financial_account_reference order by a.analysis_date desc) as bad_flag_365
from app_score_mon_2_SME a;


select * from app_score_mon_3;

drop table app_score_mon_4_SME purge;
CREATE TABLE app_score_mon_4_SME COMPRESS PCTFREE 0 PARALLEL 16 AS
select  /*+ PARALLEL(64)*/  distinct a.*/*a.entity_id,
                      a.ice_customer_id_max,
                      a.ice_id_count,
                      a.request_id,
                      a.request_type_id,
                      a.request_date_time,
                      a.request_user_id,
                      a.consent_flag,
                      a.response_id,
                      a.response_date,
                      a.response_date_time,
                      a.response_user_id,
                      a.ice_bureau_urn,
                      a.ice_bureau_flag,
                      a.bureau_id,
                      a.check_type_id,
                      a.outcome_id,
                      a.treatment_id,
                      a.option_id,
                      a.check_type,
                      a.outcome_desc,
                      a.option_description,
                      a.treatment_description,
                      a.check_sector,
                      a.score,
                      a.created_batch_run_date,
                      a.financial_account_reference,
                      a.bad_flag,
                      a.bad_flag_365*/ from app_score_mon_3_SME a;

--1.38M disticnt 

drop table app_score_mon_5_SME purge;
CREATE TABLE app_score_mon_5_SME COMPRESS PCTFREE 0 PARALLEL 16 AS
select  /*+ PARALLEL(64)*/  distinct b.entity_id,
                                     b.ice_customer_id_max,
                                     b.ice_bureau_urn,
                                     b.ice_id_count,
                                     b.request_id,
                                     b.request_type_id,
                                     b.request_date_time,
                                     b.request_user_id,
                                     b.consent_flag,
                                     b.response_id,
                                     b.response_date,
                                     b.response_date_time,
                                     b.response_user_id,
                                     b.ice_bureau_flag,
                                     b.bureau_id,
                                     b.check_type_id,
                                     b.outcome_id,
                                     b.treatment_id,
                                     b.option_id,
                                     b.check_type,
                                     b.outcome_desc,
                                     b.option_description,
                                     b.treatment_description,
                                     b.check_sector,
                                     b.rn,
                                     b.financial_account_reference,
                                     b.prov_account_status,
                                     b.cst_group_id,
                                     b.prov_pay_group_ifrs9,
                                     b.combined_liquidation,
                                     b.final_age,
                                     b.max_age,
                                     b.total_balance,
                                     b.analysis_date,
                                     b.prov_rn,
/*b.entity_id,
                b.ice_customer_id_max,
                b.ice_id_count,
                b.request_id,
                b.request_type_id,
                b.request_date_time,
                b.request_user_id,
                b.consent_flag,
                b.response_id,
                b.response_date,
                b.response_date_time,
                b.response_user_id,
                b.ice_bureau_urn,
                b.ice_bureau_flag,
                b.bureau_id,
                b.score,
                b.check_type_id,
                b.outcome_id,
                b.treatment_id,
                b.option_id,
                b.check_type,
                b.outcome_desc,
                b.option_description,
                b.treatment_description,
                b.check_sector,
                b.created_batch_run_date,*/
                max(b.bad_flag) over (partition by b.ice_customer_id_max) as bad_flag,
                max(b.bad_flag_365) over (partition by b.ice_customer_id_max) as bad_flag_365
                from app_score_mon_4_SME b ;
select * from app_score_mon_5_SME;


grant select on app_score_mon_5_SME to D30292;

select count(*) from app_score_mon_5_SME where bad_flag_365=1;
select count(*) from app_score_mon_5_SME where treatment_description like 'Dec%';
--6130 --leng:2013042
--4576 --leng:10780
