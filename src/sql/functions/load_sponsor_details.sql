-- FUNCTION: data_rpt_plaform.load_sponsor_details()

-- DROP FUNCTION IF EXISTS data_rpt_plaform.load_sponsor_details();

CREATE OR REPLACE FUNCTION data_rpt_plaform.load_sponsor_details(
	OUT p_success boolean)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    lv_event_source   VARCHAR(50);
    lv_error_code     TEXT;
    lv_error_detail   TEXT;
    lv_error_hint     TEXT;
    lv_error_context  TEXT;
    lv_event_message  TEXT;
	
BEGIN
    
	WITH qry_results as
	( 
	 SELECT S_SP.*, 
	 CASE WHEN T_SP.source_customer_num IS NULL THEN 'I'
	      WHEN S_SP.sponsor_email_val <> T_SP.sponsor_email_val OR S_SP.contact_number <> T_SP.sponsor_mobile_num THEN 'U' 
     END Ins_Upd_Flg,
	
	CASE 
    WHEN S_SP.sponsor_type = 'i' THEN 1
    WHEN S_SP.sponsor_type = 'o' THEN 2
    WHEN S_SP.sponsor_type = 'g' THEN 3
    ELSE NULL
    END Trans_sponsor_type

	FROM 
	   data_rpt_plaform.stg_sponsor S_SP
	   LEFT OUTER JOIN data_rpt_plaform.sponsor T_SP
	   ON (S_SP.sponsor_registred_number = T_SP.source_customer_num)
	   
	),
    Insert_qry As
	(
        INSERT INTO  data_rpt_plaform.Sponsor 
		(
        source_customer_num, sponsor_name, sponsor_dob, sponsor_start_dt, sponsor_email_val, 
		sponsor_abn_val, sponsor_type_cd, sponsor_mobile_num
		)
		SELECT 
		S_SP.sponsor_registred_number, S_SP.sponsor_name, S_SP.sponsor_dob, S_SP.sponsor_start_dt, 
		S_SP.sponsor_email_val, S_SP.sponsor_abn_val, S_SP.Trans_sponsor_type, contact_number
		FROM qry_results S_SP
		WHERE Ins_Upd_Flg = 'I'
	)
	UPDATE data_rpt_plaform.sponsor T_SP SET (source_customer_num, sponsor_name, sponsor_dob, sponsor_start_dt, sponsor_email_val, 
		sponsor_abn_val, sponsor_type_cd, sponsor_mobile_num)
		= (S_SP.sponsor_registred_number, S_SP.sponsor_name, S_SP.sponsor_dob, S_SP.sponsor_start_dt, 
		S_SP.sponsor_email_val, S_SP.sponsor_abn_val, S_SP.Trans_sponsor_type, contact_number)
	FROM qry_results S_SP
	     WHERE T_SP.source_customer_num = S_SP.sponsor_registred_number AND S_SP.Ins_Upd_Flg = 'U';
		 
	 
    p_success := 1;

EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS
            lv_error_code    = RETURNED_SQLSTATE,
            lv_error_detail  = PG_EXCEPTION_DETAIL,
            lv_error_hint    = PG_EXCEPTION_HINT,
            lv_error_context = PG_EXCEPTION_CONTEXT;     
        RAISE EXCEPTION USING MESSAGE = 
            lv_error_code || ', ' || lv_error_detail || ', ' || lv_error_hint || ', ' || lv_error_context;
END;
$BODY$;

ALTER FUNCTION data_rpt_plaform.load_sponsor_details()
    OWNER TO postgres;
