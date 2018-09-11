#' Retrieve a reprot via the Workday RaaS
#'
#' @param report_name
#' @param organization
#' @param username
#' @param password
#' @param params
#'
#' @export
get_workday_report <- function(
   report_name
  ,organization
  ,username
  ,password
  ,params = list()
) {
  # create url
  endpoint <- 'https://wd5-services1.myworkday.com/ccx/service/customreport2/'
  base_url <- paste0(
      endpoint
    , organization
    , "/"
    , report
  )

  # change this later to be vectorized?


  %>%
    param_set(
        key   = 'Effective_as_of_Date'
      , value = '2018-06-30-07:00'
    ) %>%
    param_set(
        key   = 'format'
      , value = 'csv'
    )

  # get csv download from response
  workday_response <- RCurl::getURL(
      url      = url
    , userpwd  = paste0(username, ":", password)
    , httpauth = 1L
  )

}

