#' @title Retrieve a report via the Workday RaaS
#'
#' @description
#' Query's the Workday Report As a Service API. A tutorial on how to use this API is located \href{https://docs.workato.com/connectors/workday/workday_raas.html}{here}
#' This function specifically uses \code{RCurl::getURL()} to return the result as text or binary. After you get the response you can use a \code{readr} function to read the result such as
#' \code{readr::read_csv}.
#'
#' @param report_name character. The name of the report. It should have the format REPORT_OWNER/REPORT_NAME you will need to pass the full string in.
#' @param organization character. The Workday organization. To find yours go to your Workday home page, the organization name is in the ulr \code{https://wd5.myworkday.com/ORGANIZATION_NAME/d/home.htmld}
#' @param username character. The username of the user who has access to the report.
#' @param password character. The password of the user who has access to the report.
#' @param url_params named vector of key value pairs. Defaults to \code{c('format'='csv')}. Common params include \code{c('Effective_as_of_date'='2018-10-01-07:00')}.
#' @param ... parameters to pass into \code{RCurl::getURL()}
#'
#' @import dplyr
#'
#' @export
get_workday_report <- function(
   report_name
  ,organization
  ,username
  ,password
  ,url_params = c('format'='csv')
  ,...
) {
  # create url
  endpoint <- 'https://wd5-services1.myworkday.com/ccx/service/customreport2/'
  query_url <- paste0(
      endpoint
    , organization
    , "/"
    , report_name
  )

  #  Loop through to add the appropriate parameters
  if (length(url_params) > 0){
    url <- query_url
    purrr::map2(names(url_params), url_params, function(key, value){
        url <<- urltools::param_set(url, key = key, value = value)
    })
  } else {
    url <- query_url
  }

  # get csv download from response
  workday_response <- RCurl::getURL(
      url      = url
    , userpwd  = paste0(username, ":", password)
    , httpauth = 1L
    , ...
  )

  return(workday_response)

}

