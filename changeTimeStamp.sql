CREATE OR REPLACE FUNCTION calc_interval()
RETURNS INTERVAL AS $$
BEGIN
RETURN (NOW() - '2017-02-20 00:00:00');
END
$$
LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION add_time(t TIMESTAMP with time zone)
RETURNS TIMESTAMP AS $$
BEGIN
RETURN (calc_interval() + t);
END
$$
LANGUAGE 'plpgsql';

UPDATE processing_periods SET startdate = add_time(startdate);
UPDATE processing_periods SET enddate = add_time(enddate);

UPDATE requisitions SET createddate = add_time(createddate);
UPDATE requisitions SET modifieddate = add_time(modifieddate);
UPDATE requisitions SET clientsubmittedtime = add_time(clientsubmittedtime);

UPDATE requisition_periods SET periodstartdate = add_time(periodstartdate);
UPDATE requisition_periods SET periodenddate = add_time(periodenddate);
UPDATE requisition_periods SET createddate = add_time(createddate);
UPDATE requisition_periods SET modifieddate = add_time(modifieddate);

UPDATE lots_on_hand SET createddate = add_time(createddate);
UPDATE lots_on_hand SET modifieddate = add_time(modifieddate);

UPDATE lots SET expirationdate = add_time(expirationdate);

UPDATE stock_card_entries SET createddate = add_time(createddate);
UPDATE stock_card_entries SET modifieddate = add_time(modifieddate);
UPDATE stock_card_entries SET occurred = add_time(occurred);

UPDATE stock_cards SET createddate = add_time(createddate);
UPDATE stock_cards SET modifieddate = add_time(modifieddate);

UPDATE program_data_forms SET startdate = add_time(startdate);
UPDATE program_data_forms SET enddate = add_time(enddate);
UPDATE program_data_forms SET submittedtime = add_time(submittedtime);
UPDATE program_data_forms SET createddate = add_time(createddate);
UPDATE program_data_forms SET modifieddate = add_time(modifieddate);



