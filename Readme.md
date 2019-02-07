# workdayr

Query Workday with R!

## Installation
  
```r
# install.packages('devtools')
devtools::install_github('blakiseskream/workdayr')
```

## Functions

There is only one!

### Query a Workday report via the Workday Report as a Service API.

Have a Workday report you want to query easily? Read up on the Workday RaaS via this documentation [here](https://docs.workato.com/connectors/workday/workday_raas.html). You can pull down Workday reports in a variety of formats including csv, json, xml (why would you do that), Excel, etc.

Function works like this
 
```r
# Get report raw data
report_path <- get_workday_report(
  report_name = 'report_owner/workday_headcount_report', 
  username = 'api_user', 
  password = 'api_password', 
  params = list(Effective_as_of_Date='2018-10-01-07:00',format='csv'), 
  organization = 'my_organization',
  filepath = tempfile(),
  overwrite = TRUE
)

# read it in as a tibble
report <- readr::read_csv(report_path)
```

Ta da!

Have fun.
