CREATE TASK mytask_hour
  WAREHOUSE = DNA_HIST_PRD
  SCHEDULE = 'USING CRON 0 9-17 * * SUN America/Los_Angeles'
  TIMESTAMP_INPUT_FORMAT = 'YYYY-MM-DD HH24'
AS
CREATE OR REPLACE VIEW STG_HDL_V_EQFX_RES_DATA_JSON AS 
 select 
   equifax_data:transactionId::string transactionId,
   equifax_data:summary:created::string created,
   equifax_data:customerReference::string customerReference,
   value:label::string label,
   value:value::number value
from  HIST_PW01.HDL.HDL_T_EQUIFAX_JSON_CONSUMER a,
   lateral flatten(input => a.equifax_data:scores:score)
   where value:label in ('RNOLF04','ENOLF04');
   
   show tasks
   
   drop task mytask_minute
   
   CREATE TASK mytask_minute
  WAREHOUSE = DNA_HIST_PRD
  SCHEDULE = '1 minute'
AS
CREATE OR REPLACE VIEW STG_HDL_V_EQFX_RES_DATA_JSON_TEST AS 
 select 
   equifax_data:transactionId::string transactionId,
   equifax_data:summary:created::string created,
   equifax_data:customerReference::string customerReference,
   value:label::string label,
   value:value::number value
from  HIST_PW01.HDL.HDL_T_EQUIFAX_JSON_CONSUMER a,
   lateral flatten(input => a.equifax_data:scores:score)
   where value:label in ('RNOLF04','ENOLF04');
   
   select *
  from table(information_schema.task_history())
  order by scheduled_time;


 select equifax_data:transactionId::string as transactionId
,     equifax_data:summary:created::date as created
,        equifax_data:summary:userName::string as createdusername
,      equifax_data:customerReference::string as customerReference
,      equifax_data:businessLine::string as businessLine
,      equifax_data:applicationDecision::string as overallApplicationDecision
,      equifax_data:decision:primaryDecisions:decisionState::string as commercialDecisionState
--,      equifax_data:decision:primaryDecisions:decisionCode::string as commercialDecisionCode
,      equifax_data:decision:primaryDecisions:decisionReason::string as commercialDecisionReason
,         equifax_data:scoresAndLimits:protectScore::number AS protectScore
 ,       ad.value:DecisionCode::string as AdditionalDecision
  from
    HIST_PW01.HDL.HDL_T_EQUIFAX_JSON_COMMERCIAL c
    join lateral flatten(input => equifax_data:decision:additionalDecisions, outer => TRUE) ad
    
    where
     overallApplicationDecision != 'Accept'
--     and ad != NULL
--   and transactionId= '9d152f7c-baed-4cb0-b11f-e64ee966dd85'
     
    order by created DESC, createdusername

 