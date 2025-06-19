---
title: User interactions
---

## Overview
Mapping between user interactions and event_type.
## Charts


<SankeyDiagram 
    data={interactions_sg} 
    title="User Interactions breakdown for SG"  
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

<SankeyDiagram 
    data={interactions_my} 
    title="User Interactions breakdown for MY"  
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
<SankeyDiagram 
    data={interactions_id} 
    title="User Interactions breakdown for ID"  
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
<SankeyDiagram 
    data={interactions_th} 
    title="User Interactions breakdown for TH"  
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
<SankeyDiagram 
    data={interactions_ph} 
    title="User Interactions breakdown for PH"  
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

The distribution of user interactions is very similar across the five markets, with Miles Earned dominating the user-interaction category in all markets. 




```sql interactions_sg
select * from pgsql.interactions
where country='SG'
```


```sql interactions_my
select * from pgsql.interactions
where country='MY'
```

```sql interactions_id
select * from pgsql.interactions
where country='ID'
```
```sql interactions_th
select * from pgsql.interactions
where country='TH'
```
```sql interactions_ph
select * from pgsql.interactions
where country='PH'
```