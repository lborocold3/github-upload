Create or replace view expn_aff_retro_return_eph as
Select v.ice_customer_id,
       v.financial_account_reference,
       v.entity_id,
       /*v.account_name,
       v.exact_name_flag,
       v.title,
       v.first_name,
       v.initials,
       v.surname,
       v.full_name,
       v.date_of_birth,
       v.address,
       v.postcode,*/
       v.affordability_segment,
       v.risk_category,
       v.model_name,
       v.model_score,
       v.total_balance,
       v.entered_collect_next_3m,
       v.collect_entry_date,
       v.entered_s_state_next_3m,
       v.max_date_entered_s_state,
       v.min_date_entered_s_state,
       v.min_date_exited_collect,
       v.analysis_date,
       v.unique_id,
       v.entity_weight,
       v.financial_weight,
       v.account_number,
       v.sp_b2_18,
       v.sp_b2_19,
       v.sp_b2_20,
       v.sp_b2_21,
       v.vm07_sp_vm1_09, 
       v.vm07_sp_vm1_11,
       v.spa_b3_22,
       v.no_mpm_npr_l3m,
       v.ptbr_l3m_npr_l3m, 
       v.ptbr_l6m_npr_l6m,
       v.no_asb_npr_l1m,
       v.cc_data_supplied,
       v.no_ca_l1m,
       v.no_ca_l3m,
       v.no_mlv_ca_l1m,
       v.no_mlv_ca_l3m,
       v.no_cld_l3m,
       v.clu_cli_l6m,
       v.clu_cli_l6m_npr_l6m,
       v.clu_npr_l1m,
       v.ptsbr_l3m_npr_l3m, 
       v.ptsbr_l6m_npr_l6m,
       v.g0specrs,
       v.g0speaam
from K26819.expn_aff_retro_return_fix v

select * from expn_aff_retro_return_eph

select * from K26819.EXPN_AFF_RETRO_RETURN_fix 

select count(*) from expn_aff_retro_return_eph

Create  table l20565.expn_aff_table_filter as
(Select a.account_number, count(distinct a.analysis_date) as countAcc from K26819.expn_aff_retro_return_fix a where a.sp_b1_15 = 1 and a.sp_a_05>1000 and a.analysis_date > to_date('31-Dec-2018 16:00', 'DD-MON-YYYY hh24:mi') group by a.account_number having count(distinct a.analysis_date)=5)

Create or replace view l20565.expn_aff_retro_cut as
select distinct a.account_number,
       a.analysis_date,
       a.sp_a_05
       --b.countAcc 
       from K26819.expn_aff_retro_return_fix a 
left join expn_aff_table_filter b 
on a.account_number=b.account_number
where a.sp_b1_15 = 1 and a.sp_a_05>1000 and a.analysis_date > to_date('31-Dec-2018 16:00', 'DD-MON-YYYY hh24:mi') and b.countAcc=5
