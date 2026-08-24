# Museum Database System 🎨🏛️

Relational database solution created for museum operations management, designed in **3rd Normal Form (3NF)** and implemented in **PostgreSQL**[cite: 1, 2].

---

## 📌 Project Overview

The database integrates core museum sectors:
* **Collection Management**: Tracks art items, creation years, estimated value, and storage locations.
* **Exhibitions & Curators**: Links curated on-site/online exhibitions with collection items[cite: 2].
* **Visitor Services & Sales**: Manages ticket sales across tiered visitor pricing (Standard, Discounted, Child)[cite: 2].
* **Analytics & Security**: Automated sales revenue reporting per quarter and role-based read-only access control.

---

## 🗄️ Database Architecture

The system consists of **8 interconnected tables**:

[author] ──────< (collection_author) >────── [collection]
                                                   │
                                         (exhibition_items)
                                                   │
[visitor] ──┐                                      ▼
            ├──> [ticket] <── [staff] ───> [exhibition]

* **Main Tables**: `author`, `collection`, `staff`, `visitor`, `exhibition`, `ticket`[cite: 2].
* **Junction Tables (M:N)**: `collection_author`, `exhibition_items`[cite: 2].

---

## 🛠️ Tech Features

* **Data Integrity**: Enforces custom `CHECK` constraints (date boundaries > 2026-01-01, non-negative prices, predefined enumerated types) and natural `UNIQUE` constraints[cite: 1, 2, 3].
* **PL/pgSQL Functions**:
  * `update_collection(...)` – Dynamic column update with internal type casting[cite: 2, 3].
  * `add_ticket(...)` – Transaction function creating ticket entries via natural key lookups and dynamic pricing calculation[cite: 2, 3].
* **Analytics View**: `sales_revenue` automatically groups ticket sales and totals for the latest recorded quarter[cite: 1, 2, 3].
* **Security Control**: `manager` role with read-only permissions (`SELECT`) created following the principle of least privilege[cite: 1, 2, 3].

---

## 📂 Repository Structure

```text
├── SQL_Greta_Tautaviciute_FinalTask_Museum_ConceptModel.png
├── SQL_Greta_Tautaviciute_FinalTask_Museum_LogicalModel.png
├── SQL_Greta_Tautaviciute_FinalTask_Museum_descriptions.docx
└── SQL_Greta_Tautaviciute_FinalTask_Museum_Scripts.sql
```

🚀 How to Run
Open PostgreSQL or DBeaver[cite: 2].

Execute SQL_Greta_Tautaviciute_FinalTask_Museum_Scripts.sql to build the schema, populate mock data, and set up functions, views, and roles[cite: 1, 2, 3].
