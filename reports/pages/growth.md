---
title: User growth
---

<Details title='Definitions'>

We explore growth as a metric in 3 granularities, namely month, week and day.


Monthly active user is defined as: 
- `MAU(t) = New(t) + Retained(t) + Resurrected(t)`

MAU growth is defined as:
- `Growth(t) = New(t) + Resurrected(t) - Churned(t)`

where:
    1. *resurrected users are users who have logged in previously but was not active in the last time window that we consider, i.e. resurrected users in June are users whose last seen was in April or before.*
    2. *churned users are users who who have logged in previously but was not active in the current time window, i.e. churned users in June are users whose last seen was before June.*


</Details>

## Overview of active users across all countries
<br>

<LineChart
    data={active_users_month}
    title="Monthly active users across all countries"
    x=period
    y=active_users
    yAxisTitle='User Count'
    markers=true
    markerSize=5
    colorPalette={['violet','seagreen', 'red', 'darkorange','indigo']}
    series=country
/>


<LineChart
    data={active_users_week}
    title="Weekly active users across all countries"
    x=period
    y=active_users
    yAxisTitle='User Count'
    markers=true
    colorPalette={['violet','seagreen', 'red', 'darkorange','indigo']}
    series=country
/>


<LineChart
    data={active_users_day}
    title="Daily active users across all countries"
    x=period
    y=active_users
    markers=true
    yAxisTitle='User Count'
    markerSize=5
    colorPalette={['violet','seagreen', 'red', 'darkorange','indigo']}
    series=country
/>

## Active users by country

<br>
<Dropdown data={countries} name=country value=country defaultValue='SG'>
</Dropdown>


<BarChart
    data={user_metrics_by_country_month}
    title="Monthly active user by country, {inputs.country.label}"
    x=period
    y=user_count
    yAxisTitle='User Count'
    series=user_category
/>

In this dataset, new users are acquired only in March, and are retained every month. Hence, no churned users or resurrected users when `granularity = month`.


<LineChart
    data={growth_by_month}
    title="Monthly user growth by country, {inputs.country.label}"
    x=period
    y=growth
    markers=true
    markerSize=5
    yAxisTitle='User Count (New+Resurrected)'
/>

Since growth is defined as `New + Resurrected`, we observe a decline in growth as time goes on from Mar to Jun, because there are no new users or resurrected users when `granularity = month`.

<BarChart
    data={user_metrics_by_country_week}
    title="Weekly active user by country, {inputs.country.label}"
    x=period
    y=user_count
    series=user_category
    yAxisTitle='User Count'
/>

At `granularity=week`, new users are observed in the first and second week of Mar. In the second week of Mar, both new and retained users (from week. 1) are observed. Subsequently, there are no more new user signups and only retained users at this granularity, which means users come back every week.

<LineChart
    data={growth_by_week}
    title="Weekly user growth by country, {inputs.country.label}"
    x=period
    y=growth
    markers=true
    markerSize=5
    yAxisTitle='User Count (New+Resurrected)'
/>

Similar to what we observed at monthly granularity, there is a decline in growth as time goes on from Mar to Jun.

<BarChart
    data={user_metrics_by_country_day}
    title="Daily active user  by country, {inputs.country.label}"
    x=period
    y=user_count
    series=user_category
    yAxisTitle='User Count'
/>

At `granularity=day`, we observe a varying number of retained and resurrected users everyday. Overall, there are a lot more retained users and resurrected users, indicating that there is a relative bigger group of usrs who comes back everyday.

<LineChart
    data={growth_by_day}
    title="Daily user growth by country, {inputs.country.label}"
    x=period
    y=growth
    markers=true
    markerSize=5
    yAxisTitle='User Count (New+Resurrected)'
   />

<!-- couldn't fix the duplicates in tooltip, no way to customize colours as well -->
<!-- <Chart data={growth_by_day}>
    <Bar x=period y=user_count series=user_category/>
    <Line x=period y=growth/>
</Chart> -->


At `granularity=day`, we can see that growth is negative on some days. This happens when you have more churned users than new and resurrected users.


    






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
select distinct period, country, n+r-c as growth, unnest(
                ARRAY['New', 'Retained', 'Churned']
            ) AS user_category,
            unnest(ARRAY[n, r, -c]) AS user_count,
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
<!-- plot new + resurrected - churned on the same graph -->

```sql active_users_month
select distinct period::date as period,
country,
    active_users
from pgsql.growth_metrics_month
```

```sql active_users_week
select distinct period::date as period,
country,
    active_users
from pgsql.growth_metrics_week
```

```sql active_users_day
select distinct period::date as period,
country,
    active_users
from pgsql.growth_metrics_day
```