# Governance

How models in this project are owned, exposed, and classified. Defined before the first model so nothing needed retrofitting. Groups live in `dbt/models/_groups.yml`.

## Groups & ownership

Sources are the three jaffle-shop seeds (`raw_customers`, `raw_orders`, `raw_payments`), everything below builds on them.

| Group | Owner | Owns |
|---|---|---|
| `core` | Core Data Team (`core@jaffle.example`) | All staging models, shared dims (`dim_customers`), utilities (`dim_date`) |
| `finance` | Finance Analytics (`finance@jaffle.example`) | Finance intermediates (`int_finance__*`) and revenue marts (`fct_orders`, `agg_daily_revenue`) |
| `marketing` | Marketing Analytics (`marketing@jaffle.example`) | Customer-behavior marts (`mart_customer_activity`) |

Rules:

- Every mart declares exactly one `group`. Staging defaults to `core`; intermediate folders are organized per business group (`intermediate/<group>/`), which sets their ownership.
- The owner emails are intentionally fake (`.example` is reserved, RFC 2606), this is a lab.
- Folder convention: `models/marts/<group>/…`, with the matching `+group` wiring in `dbt_project.yml`.

## Access policy

| Layer | Access | Why |
|---|---|---|
| staging, intermediate | `protected` (dbt's default) | Usable by marts in *any* group within this project. Never `private`: private blocks refs from other groups, so a `finance` mart couldn't ref a `core` staging model. |
| marts | `protected` by default | Same-project use only; not visible to other dbt projects. |
| marts, selected | `public` (the exception) | Cross-project consumption. Requires ALL of: enforced contract (`contract: {enforced: true}` + typed columns), a group, and a versioning commitment: breaking changes ship as a new version with a `deprecation_date` on the old one. No model is `public` today, this project has no downstream consumers. |
| group-internal helpers | `private` (rare) | Only for models that genuinely must not be ref'd outside their own group. |

## Tags

| Tag | Meaning | Used by |
|---|---|---|
| `critical` | Failure should block CI | CI selectors |
| `contract` | Model has an enforced contract | contract-change checks in CI |
| `pii` | Contains personal data (jaffle: customer names) | audits, masking decisions |
| `data_quality` | Test-heavy audit model | quality-focused selections (`--select tag:data_quality`) |

## Meta convention

```yaml
meta:
  criticality: high | medium | low
  pii: true | false
```

Domain is implied by the group, not duplicated in `meta`.
