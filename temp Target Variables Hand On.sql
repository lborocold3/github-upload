select * from all_tab_columns where table_name like '%DIM%' and table_name like '%BASE_TYPE%';

select * from DIM_V_BASE_TYPE;

select * from K26819.EQUIFAX_LEG_SEG_DATA;

select * from all_tab_columns where column_name like '%END_REASON%';

select * from HDS_T_ICE1_BASE;

Select * FROM ae_hds.hds_t_ice2_base

SELECT    *
FROM      dim_t_date
WHERE     full_date BETWEEN TO_DATE('01-Feb-2020','DD-Mon-YYYY') AND TO_DATE('30-Jun-2020','DD-Mon-YYYY') 
AND       day_of_week = 6

SELECT    /*+ PARALLEL(64)*/ a.start_date, 
          a.from_date,
          a.start_date
          a.end_date,
          a.to_date,
          a.end_date,
          a.ice_customer_id,
          a.account_reference,
          a.base_id, 
          a.premise_id,
          a.key_type,
          DECODE(a.key_type, 1, 'E', 2, 'G', 14, 'G', 'E') product_code, --Leng: anything else go electric
          a.product_status,--Leng: Dim table checked see oneNote
          1 domain
FROM      ae_hds.hds_t_ice1_base a
