# China Mainland 985 Thesis LaTeX Templates

An indexed collection of GitHub-hosted LaTeX thesis templates for mainland China 985 universities.

Current scope:

- Mainland China 985 universities only
- Thesis / dissertation / graduation project templates only
- GitHub repositories only
- School-level records plus repository-level evidence

This project is intentionally conservative. A school is only marked as covered when at least one GitHub repository has been identified and manually recorded.

## Snapshot

- Schools tracked: `39`
- Schools with at least one recorded repository: `32`
- Schools still unverified after the first search pass: `7`

## Current Unverified Schools

- 北京大学
- 北京师范大学
- 中国农业大学
- 中央民族大学
- 南开大学
- 中国海洋大学
- 西北农林科技大学

## Seed Repositories

| University | Repository | Status |
| --- | --- | --- |
| 清华大学 | `tuna/thuthesis` | active |
| 北京理工大学 | `BITNP/BIThesis` | active |
| 北京航空航天大学 | `CheckBoxStudio/BUAAThesis` | unknown |
| 哈尔滨工业大学 | `hithesis/hithesis` | active |
| 复旦大学 | `stone-zeng/fduthesis` | active |
| 上海交通大学 | `sjtug/SJTUThesis` | active |
| 南京大学 | `nju-lug/NJUThesis` | active |
| 浙江大学 | `TheNetAdmin/zjuthesis` | active |
| 中国科学技术大学 | `ustctug/ustcthesis` | active |
| 武汉大学 | `whutug/whu-thesis` | active |
| 中南大学 | `CSUcse/CSUthesis` | unknown |
| 华南理工大学 | `mengchaoheng/SCUT_thesis` | active |
| 电子科技大学 | `bdebye/thesisuestc` | active |
| 西安交通大学 | `obster-y/XJTU-thesis` | unknown |
| 西北工业大学 | `NWPUMetaphysicsOffice/Yet-Another-LaTeX-Template-for-NPU-Thesis` | unknown |

## Status Definitions

- `covered`: at least one matching GitHub repository has been recorded
- `unverified`: no matching repository has been manually recorded yet
- `archived`: matching repositories exist but appear archived or no longer maintained

## Repository Inclusion Rules

- Must be hosted on GitHub
- Must primarily target thesis, dissertation, or graduation project writing
- Must be clearly associated with a mainland China 985 university
- Course reports, resumes, slides, and generic article templates are excluded

## Directory Layout

```text
schema/
  mainland-985.schema.json
data/
  mainland-985.json
```

## Data Fields

- `school_id`: stable ASCII identifier
- `school_name_zh`: Chinese school name
- `school_name_en`: English school name
- `city`: primary city
- `province`: province-level region
- `project_985`: whether the university belongs to Project 985
- `status`: collection status for this school
- `notes`: short manual note
- `templates`: recorded GitHub repositories for this school

Template fields:

- `name`: template or repository short name
- `repo`: `owner/name`
- `url`: GitHub repository URL
- `degree_types`: supported document types
- `official_status`: `official`, `community`, or `unknown`
- `maintenance_status`: `active`, `inactive`, `archived`, or `unknown`
- `last_verified`: manual verification date in `YYYY-MM-DD`
- `evidence`: short evidence statement used during manual curation

## Initial Coverage

The first version contains all mainland China 985 universities as school records and a seed set of confirmed GitHub repositories for a subset of schools.

## Next Steps

- Expand coverage to all 39 mainland 985 universities
- Add automated schema validation
- Add generated tables for active templates and missing schools
- Add contribution guidelines for submitting new repositories
