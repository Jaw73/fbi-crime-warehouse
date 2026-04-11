# FBI Crime Analytics Warehouse

End-to-end analytics engineering project building a dimensional warehouse on top of the FBI Crime Data Explorer API, modeled in dbt on Snowflake.

## Status

**Phase 8 complete — Snowflake infrastructure provisioned.**
Next session: `dbt init`, configure profile, run `dbt debug`, write first staging model.

## Stack

- **Warehouse:** Snowflake (Enterprise edition, AWS us-east-1)
- **Transformation:** dbt-core 1.11.8 + dbt-snowflake 1.11.4
- **Source:** FBI Crime Data Explorer API (api.usa.gov/crime/fbi/cde)
- **Version control:** Git + GitHub

## Architecture Decisions

### Source data and grain
The FBI Crime Data Explorer API returns **monthly aggregated** offense data per agency, not incident-level records. The original design called for an incident-victim grain, but inspection of the actual API response showed only summary endpoints are exposed publicly. Rather than fighting the source, the warehouse is modeled as a **periodic snapshot fact table** at the lowest grain the API actually provides: one row per agency per offense per month. This is the textbook Kimball move — model at the source's true grain, never finer.

### State scope
**Tennessee** was chosen over Pennsylvania because TN has 99.5% NIBRS reporting coverage (410 of 412 agencies) vs PA's 17% coverage (239 of 1,440). Tennessee delivers a complete, defensible warehouse; Pennsylvania would have produced a thin slice of mostly rural State Police data. PA is on the v2 roadmap as a "partial reporter" case study.

### Dimensional model
- **fct_offense_monthly** — periodic snapshot fact, one row per (month, agency, offense)
- **dim_date** — month grain
- **dim_agency** — SCD Type 2 candidate (agencies change names, NIBRS status)
- **dim_offense** — Type 1, small slowly-changing dim

### RBAC
Snowflake provisioned with least-privilege principles: a dedicated `FBI_DBT_ROLE` with grants only to project schemas, and a dedicated service user `FBI_DBT_USER` that holds only that role. dbt connects via the service user, never as `ACCOUNTADMIN`. See `infrastructure/snowflake_setup.sql`.

## Project Structure
