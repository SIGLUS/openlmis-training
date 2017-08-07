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

CREATE OR REPLACE FUNCTION make_date(year INTEGER, month INTEGER, day INTEGER)
RETURNS TIMESTAMP AS $$
BEGIN
  RETURN format('%s-%s-%s', year, month, day)::DATE;
END
$$
LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION convert_to_period_start(t TIMESTAMP with time zone)
RETURNS TIMESTAMP AS $$
BEGIN
  IF (extract(day from t) >= 21)
  THEN
    RETURN make_date(extract(year from t)::INTEGER, extract(month from t)::INTEGER, 21);
  ELSE
    IF (extract(month from t) = 1)
    THEN
      RETURN make_date((extract(year from t)-1)::INTEGER, 12, 21);
    ELSE
      RETURN make_date(extract(year from t)::INTEGER, (extract(month from t) - 1)::INTEGER, 21);
    END IF;
  END IF;
END
$$
LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION convert_to_period_end(t TIMESTAMP with time zone)
RETURNS TIMESTAMP AS $$
BEGIN
  IF (extract(day from t) <= 20)
  THEN
    RETURN make_date(extract(year from t)::INTEGER, extract(month from t)::INTEGER, 20);
  ELSE
    IF (extract(month from t) = 12)
    THEN
      RETURN make_date((extract(year from t)+1)::INTEGER, 1, 20);
    ELSE
      RETURN make_date(extract(year from t)::INTEGER, (extract(month from t) + 1)::INTEGER, 20);
    END IF;
  END IF;
END
$$
LANGUAGE 'plpgsql';

UPDATE processing_periods SET startdate = convert_to_period_start(add_time(startdate));
UPDATE processing_periods SET enddate = convert_to_period_end(add_time(enddate));

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

UPDATE cmm_entries SET periodbegin = convert_to_period_start(add_time(periodbegin));
UPDATE cmm_entries SET periodend = convert_to_period_end(add_time(periodend));

UPDATE program_data_forms SET startdate = convert_to_period_start(add_time(startdate));
UPDATE program_data_forms SET enddate = convert_to_period_end(add_time(enddate));
UPDATE program_data_forms SET submittedtime = add_time(submittedtime);
UPDATE program_data_forms SET createddate = add_time(createddate);
UPDATE program_data_forms SET modifieddate = add_time(modifieddate);



