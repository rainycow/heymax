---
title: User growth
---

<Details title='Definitions'>

We explore growth as a metric in 3 granularities, namely month, week and day.


Monthly active user is defined as: 
- MAU(t) = new(t) + retained(t) + resurrected(t)

MAU growth is defined as:
- Growth(t) = new(t) + resurrected(t) - churned(t)

where:
    1. *resurrected users are users who have logged in previously but was not active in the last time window that we consider, i.e. resurrected users in June are users whose last seen was in April or before.*
    2. *churned users are users who who have logged in previously but was not active in the current time window, i.e. churned users in June are users whose last seen was before June.*


</Details>

## Growth metrics charts

<Dropdown data={countries} name=country value=country defaultValue='SG'>
</Dropdown>

<Dropdown data={user_cat} name=category value=user_category>
    <DropdownOption value="%" valueLabel="All Categories"/>
</Dropdown>


<AreaChart
    data={user_metrics_by_country_month}
    title="Monthly active user by country, {inputs.country.label}"
    x=period
    y=user_count
    series=user_category
/>

In this dataset, new users are acquired only in March, and are retained every month. Hence, no churned users or resurrected users.

<LineChart
    data={growth_by_month}
    title="Monthly user growth by country, {inputs.country.label}"
     x=period
    y=growth
    y2=churn
    y2SeriesType=bar
    markers=true
    markerSize=5
    yMin=-5
    yMax=30
    y2Min=-5
    y2Max=20
    yBaseline=true
    y2Baseline=true
    colorPalette={['steelblue', 'navajowhite']}
/>


<AreaChart
    data={user_metrics_by_country_week}
    title="Weekly active user by country, {inputs.country.label}"
    x=period
    y=user_count
    series=user_category
/>

<LineChart
    data={growth_by_week}
    title="Weekly user growth by country, {inputs.country.label}"
    x=period
    y=growth
    y2=churn
    y2SeriesType=bar
    markers=true
    markerSize=5
    yMin=-5
    yMax=30
    y2Min=-5
    y2Max=30
    yBaseline=true
    y2Baseline=true
    colorPalette={['steelblue', 'navajowhite']}
/>

<AreaChart
    data={user_metrics_by_country_day}
    title="Daily active user  by country, {inputs.country.label}"
    x=period
    y=user_count
    series=user_category
/>

<LineChart
    data={growth_by_day}
    title="Daily user growth by country, {inputs.country.label}"
    x=period
    y=growth
    y2=churn
    y2SeriesType=bar
    markers=true
    markerSize=5
    yMin=-10
    yMax=20
    y2Min=-10
    y2Max=20
    yBaseline=true
    y2Baseline=true
    colorPalette={['steelblue', 'navajowhite']}
/>



```sql countries
select distinct country
from pgsql.growth_metrics_month
```
```sql user_cat
select distinct user_category
from pgsql.growth_metrics_month
```

```sql user_metrics_by_country_month
select period::date as period,
country,
    user_category,
    user_count,
    active_users
from pgsql.growth_metrics_month
where country like '${inputs.country.value}'
and user_category!='churned_users'
```



```sql growth_by_month
select period, country, n, -c as churn, r, n+r-c as growth
            from(
select period::date as period,
country,
sum(case when user_category = 'new_users' then user_count end) as n,
sum(case when user_category = 'resurrected_users' then user_count end) as r,
sum(case when user_category = 'churned_users' then user_count end) as c
from pgsql.growth_metrics_month
group by 1,2
)t1
where country like '${inputs.country.value}'
```



```sql user_metrics_by_country_week
select period::date as period,
country,
    user_category,
    user_count,
    active_users
from pgsql.growth_metrics_week
where country like '${inputs.country.value}'
and user_category!='churned_users'
```


```sql growth_by_week
select period, country, n, -c as churn, r, n+r-c as growth
            from(
select period::date as period,
country,
sum(case when user_category = 'new_users' then user_count end) as n,
sum(case when user_category = 'resurrected_users' then user_count end) as r,
sum(case when user_category = 'churned_users' then user_count end) as c
from pgsql.growth_metrics_week
group by 1,2
)t1
where country like '${inputs.country.value}'
```


```sql user_metrics_by_country_day
select period::date as period,
country,
    user_category,
    user_count,
    active_users
from pgsql.growth_metrics_day
where country like '${inputs.country.value}'
and user_category!='churned_users'
```



```sql growth_by_day
select period, country, n, -c as churn, r, n+r-c as growth
            from(
select period::date as period,
country,
sum(case when user_category = 'new_users' then user_count end) as n,
sum(case when user_category = 'resurrected_users' then user_count end) as r,
sum(case when user_category = 'churned_users' then user_count end) as c
from pgsql.growth_metrics_day
group by 1,2
)t1
where country like '${inputs.country.value}'
```