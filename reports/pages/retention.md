---
title: User retention
---

<Details title='Definitions'>

Earlier in User Growth we briefly looked at the distribution of retained users over a period of 3 months from Mar to Jun. Here we explore user retention rate in greater details.

<span style="font-size:15px;">We define user retention rate as follows: </span>

<br><br>

<span style="font-style: italic; font-size:14px;"> Retention = (Users_END - Users_NEW)x100/(Users_START)</span>

<br><br>

<ul>
  <li><span style="font-size:11px;">Users_END = number of Users at the end of the time period </span></li>
  <li><span style="font-size:11px;">Users_NEW = number of Users who signup during the period</span></li>
  <li><span style="font-size:11px;">Users_START = number of Users at the start of the period</span></li>
</ul>

<br>

Here, we assign users into different cohorts according to their signup date. We then look at the number of users that remained in their respective cohorts at different time periods, e.g. 7 days, 1 month, 2 months etc.

</Details>

## Charts

<Dropdown data={countries} name=country value=country defaultValue='SG'>
</Dropdown>


<DataTable data={retention}>
    <Column id=signup_date/>
	<Column id=country/>
    <Column id=d0_retention_rate title="Day0 Retention Rate" contentType=bar barColor=#D76C82/>
	<Column id=d1_retention_rate title="Day1 Retention Rate" contentType=bar barColor=#FEC5F6/>
  	<Column id=d7_retention_rate title="Day7 Retention Rate" contentType=bar barColor=#DC8BE0/>
  	<Column id=d30_retention_rate title="Day30 Retention Rate" contentType=bar barColor=#DB8DD0/> 
    <Column id=d60_retention_rate title="Day60 Retention Rate" contentType=bar barColor=#C562AF/>
    <Column id=d90_retention_rate title="Day90 Retention Rate" contentType=bar barColor=#B33791/>

</DataTable>


```sql retention
select cohort_date::date as signup_date, country, cohort_size, 
d0_retention_rate,
d1_retention_rate, d7_retention_rate, d30_retention_rate, 
d60_retention_rate, d90_retention_rate 
from 
pgsql.retention
where country like '${inputs.country.value}'
order by cohort_date
```

```sql countries
select distinct country
from pgsql.growth_metrics_month
```
