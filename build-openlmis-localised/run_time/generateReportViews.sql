CREATE OR REPLACE VIEW vw_rapid_test AS
  SELECT
    uuid_in(md5(random() :: TEXT || now() :: TEXT) :: cstring) AS uuid,
    data_items.name                     AS item_name,
    data_items.value                    AS item_value,
    data_items.formid                   AS formid,
    colums.code                         AS column_code,
    data_forms.facilityid               AS facilityid,
    facilities.name                     AS facility_name,
    facilities.code                     AS facility_code,
    zone.name                           AS district_name,
    zone.code                           AS district_code,
    parent_zone.name                    AS province_name,
    parent_zone.code                    AS province_code,

    data_forms.supplementalprogramid    AS supplementalprogramid,
    supplemental_programs.code          AS form_code,
    supplemental_programs.name          AS form_name,
    supplemental_programs.description   AS form_description,

    data_forms.modifiedby               AS modifyby,
    data_forms.createdby                AS createdby,
    data_forms.startdate                AS startdate,
    data_forms.enddate                  AS enddate
  FROM program_data_items AS data_items
    JOIN program_data_columns AS colums ON data_items.programdatacolumnid = colums.id
    JOIN program_data_forms AS data_forms ON data_forms.id = data_items.formid
    JOIN facilities ON facilities.id = data_forms.facilityid
    JOIN geographic_zones AS zone ON facilities.geographiczoneid = zone.id
    JOIN geographic_zones AS parent_zone ON zone.parentid = parent_zone.id
    JOIN supplemental_programs ON supplemental_programs.id = data_forms.supplementalprogramid;

CREATE MATERIALIZED VIEW vw_lot_expiry_dates AS

  SELECT
    uuid_in(md5(random() :: TEXT || now() :: TEXT) :: cstring) AS uuid,

    lots.lotnumber      AS lot_number,
    lots.expirationdate AS expiration_date,
    stock_entry_loh.*
  FROM
    (SELECT
      stock_card_entries.id AS stock_card_entry_id,
      facilities.name      AS facility_name,
      facilities.code      AS facility_code,
      zone.name            AS district_name,
      zone.code            AS district_code,
      parent_zone.name     AS province_name,
      parent_zone.code     AS province_code,
      products.code        AS drug_code,
      products.primaryname AS drug_name,
      (EXTRACT(EPOCH FROM stock_card_entries.createddate) * 1000) AS createddate,
      (EXTRACT(EPOCH FROM stock_card_entries.occurred) * 1000) AS occurred,
      stock_card_entry_key_values.keycolumn AS lot_id,
      NULLIF(stock_card_entry_key_values.valuecolumn, '')::int AS lot_on_hand
    FROM facilities
      JOIN geographic_zones AS zone ON facilities.geographiczoneid = zone.id
      JOIN geographic_zones AS parent_zone ON zone.parentid = parent_zone.id
      JOIN stock_cards ON facilities.id = stock_cards.facilityid
      JOIN products ON stock_cards.productid = products.id
      JOIN stock_card_entries ON stock_cards.id = stock_card_entries.stockcardid
      JOIN stock_card_entry_key_values ON stock_card_entries.id = stock_card_entry_key_values.stockcardentryid
    WHERE stock_card_entry_key_values.keycolumn LIKE 'LOT#%'
    ORDER BY facility_code, drug_code, occurred, stock_card_entries.id DESC) stock_entry_loh
  JOIN lots
  ON stock_entry_loh.lot_id = ('LOT#' || lots.id);

CREATE UNIQUE INDEX idx_vw_lot_expiry_dates ON vw_lot_expiry_dates (stock_card_entry_id, uuid);

CREATE MATERIALIZED VIEW vw_daily_full_soh AS
  (SELECT
     DISTINCT ON (facility_code, drug_code, occurred)
     stock_card_entries.id                                                    AS stock_card_entry_id,
     facilities.name                                                          AS facility_name,
     facilities.code                                                          AS facility_code,
     facilities.id                                                            AS facility_id,

     ZONE.name                                                                AS district_name,
     ZONE.code                                                                AS district_code,

     parent_zone.name                                                         AS province_name,
     parent_zone.code                                                         AS province_code,

     products.code                                                            AS drug_code,
     products.primaryname                                                     AS drug_name,

     set_value(stock_card_entries.id, 'soh')                                  AS soh,
     soonest_expiry_date(set_value(stock_card_entries.id, 'expirationdates')) AS soonest_expiry_date,

     occurred,
     stock_cards.modifieddate                                                 AS last_sync_date,
     uuid_in(md5(random() :: TEXT || now() :: TEXT) :: cstring)               AS uuid

   FROM stock_card_entries
     JOIN stock_cards ON stock_card_entries.stockcardid = stock_cards.id
     JOIN products ON stock_cards.productid = products.id
     JOIN facilities ON stock_cards.facilityid = facilities.id
     JOIN geographic_zones AS ZONE ON facilities.geographiczoneid = ZONE.id
     JOIN geographic_zones AS parent_zone ON ZONE.parentid = parent_zone.id
   ORDER BY facility_code, drug_code, occurred, stock_card_entries.createddate DESC);

CREATE UNIQUE INDEX idx_vw_daily_full_soh ON vw_daily_full_soh (uuid, stock_card_entry_id);

CREATE MATERIALIZED VIEW vw_stockouts AS
  SELECT
    uuid_in(md5(random() :: TEXT || now() :: TEXT) :: cstring) AS uuid,

    facilities.name             AS facility_name,
    facilities.code             AS facility_code,
    zone.name                   AS district_name,
    zone.code                   AS district_code,
    parent_zone.name            AS province_name,
    parent_zone.code            AS province_code,
    products.code               AS drug_code,
    products.primaryname        AS drug_name,
    programs.name               AS program,
    stock_card_entries.occurred AS stockout_date,
    (calculate_each_month_duration(stock_cards.id, stock_card_entries.occurred, stockcardentryid)).*
  FROM facilities
    JOIN geographic_zones AS zone ON facilities.geographiczoneid = zone.id
    JOIN geographic_zones AS parent_zone ON zone.parentid = parent_zone.id
    JOIN stock_cards ON facilities.id = stock_cards.facilityid
    JOIN products ON stock_cards.productid = products.id
    JOIN program_products ON products.id = program_products.productid
    JOIN programs ON program_products.programid = programs.id
    JOIN stock_card_entries ON stock_cards.id = stock_card_entries.stockcardid
    JOIN stock_card_entry_key_values ON stock_card_entries.id = stock_card_entry_key_values.stockcardentryid
  WHERE keycolumn = 'soh' AND valuecolumn = '0' AND stock_card_entries.quantity != 0
  ORDER BY facility_code, drug_code, stockout_date, overlapped_month, stockcardentryid;

CREATE UNIQUE INDEX idx_vw_stockouts ON vw_stockouts (uuid);

CREATE MATERIALIZED VIEW vw_carry_start_dates AS
  SELECT
    uuid_in(md5(random() :: TEXT || now() :: TEXT) :: cstring) AS uuid,

    facilities.name                     AS facility_name,
    facilities.code                     AS facility_code,
    ZONE.name                           AS district_name,
    ZONE.code                           AS district_code,
    parent_zone.name                    AS province_name,
    parent_zone.code                    AS province_code,
    products.code                       AS drug_code,
    products.primaryname                AS drug_name,
    facilities.golivedate               AS facility_golive_date,
    facilities.godowndate               AS facility_godown_date,
    first_movement_date(stock_cards.id) AS carry_start_date
  FROM stock_cards
    JOIN facilities ON stock_cards.facilityid = facilities.id
    JOIN products ON stock_cards.productid = products.id
    JOIN geographic_zones AS ZONE ON facilities.geographiczoneid = ZONE.id
    JOIN geographic_zones AS parent_zone ON ZONE.parentid = parent_zone.id
  ORDER BY facility_code, carry_start_date;

CREATE UNIQUE INDEX idx_vw_carry_start_dates ON vw_carry_start_dates (uuid);

CREATE MATERIALIZED VIEW vw_weekly_tracer_soh AS
(SELECT
 uuid_in(md5(random() :: TEXT || now() :: TEXT) :: cstring) AS uuid,
 *
 FROM tracer_drugs_weekly_stock_history());

CREATE UNIQUE INDEX idx_vw_weekly_tracer_soh ON vw_weekly_tracer_soh (uuid);

CREATE MATERIALIZED VIEW vw_period_movements AS
  (SELECT
     uuid_in(md5(random() :: TEXT || now() :: TEXT) :: cstring) AS uuid,

     periodStart,
     periodEnd,

     facilities.name                                            AS facility_name,
     products.primaryname                                       AS drug_name,
     facilities.code                                            AS facility_code,
     products.code                                              AS drug_code,
     parent_zone.name                                           AS province_name,
     parent_zone.code                                           AS province_code,
     ZONE.name                                                  AS district_name,
     ZONE.code                                                  AS district_code,

     soh_of_day(stockcardid, periodEnd :: DATE) :: INTEGER      AS soh,
     cmm_of(stockcardid, periodStart, periodEnd)                AS cmm,

     (total_quantity_and_occurrences(stockcardid, periodStart,
                                     periodEnd)).*

   FROM (SELECT
           startdate                            AS periodStart,
           enddate                              AS periodEnd,
           existing_card_ids_in_period(enddate) AS stockcardid
         FROM processing_periods) AS cardIdsInPeriods
     JOIN stock_cards ON cardIdsInPeriods.stockcardid = stock_cards.id
     JOIN facilities ON stock_cards.facilityid = facilities.id
     JOIN products ON stock_cards.productid = products.id
     JOIN geographic_zones AS ZONE
       ON facilities.geographiczoneid = ZONE.id
     JOIN geographic_zones AS parent_zone
       ON ZONE.parentid = parent_zone.id);

CREATE UNIQUE INDEX idx_vw_period_movements ON vw_period_movements (uuid,periodStart,periodEnd,facility_code);


DROP MATERIALIZED VIEW IF EXISTS vw_cmm_entries;

CREATE MATERIALIZED VIEW vw_cmm_entries AS
  SELECT
    uuid_in(md5(random() :: TEXT || now() :: TEXT) :: cstring) AS uuid,
    cmm_entries.id                      AS id,
    (CASE WHEN cmm_entries.cmmvalue=-1 THEN NULL
    ELSE cmm_entries.cmmvalue END)      AS cmmvalue,
    cmm_entries.productcode             AS productcode,
    cmm_entries.facilityid              AS facilityid,
    facilities.code                     AS facilityCode,
    cmm_entries.periodbegin             AS periodbegin,
    cmm_entries.periodend               AS periodend,
    zone.name                           AS district_name,
    zone.code                           AS district_code,
    parent_zone.name                    AS province_name,
    parent_zone.code                    AS province_code
  FROM cmm_entries AS cmm_entries
    JOIN facilities ON facilities.id = cmm_entries.facilityid
    JOIN geographic_zones AS zone ON facilities.geographiczoneid = zone.id
    JOIN geographic_zones AS parent_zone ON zone.parentid = parent_zone.id;

CREATE UNIQUE INDEX idx_vw_cmm_entries ON vw_cmm_entries (uuid, facilitycode, productcode);

CREATE OR REPLACE FUNCTION refresh_vw_cmm_entries()
  RETURNS INT LANGUAGE plpgsql
AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY vw_cmm_entries;
  RETURN 1;
END $$;
