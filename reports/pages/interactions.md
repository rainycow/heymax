---
title: User interactions
---

## Overview
Mapping between user interactions and event_type.
## Charts

<Dropdown data={countries} name=country value=country defaultValue='SG'>
</Dropdown>

<SankeyDiagram 
    data={interactions} 
    title="User Interactions breakdown, {inputs.country.label}"  
    sourceCol=event_type 
    targetCol=transaction_category 
    valueCol=interactions 
    percentCol=perc
    nodeAlign=left
    linkColor=base-content-muted
    linkLabels=percent
    nodeLabels=full
    sort=true
    echartsOptions={{
    tooltip: {
        trigger: "axis",
    }
}}
/>


Miles Earned dominates the user-interaction category in all markets. 


```sql countries
select distinct country
from pgsql.growth_metrics_month
```
```sql user_cat
select distinct user_category
from pgsql.growth_metrics_month
```


```sql interactions
select * from pgsql.interactions
where country like '${inputs.country.value}'
```

