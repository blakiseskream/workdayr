#' @title Retrieve a report via the Workday RaaS
#'
#' @description
#' Query's the Workday Report As a Service API. A tutorial on how to use this API is located \href{https://docs.workato.com/connectors/workday/workday_raas.html}{here}
#' This function specifically uses \code{httr::GET()} to return the result as http_response or binary. After you get the response you can use a \code{readr} function to read the result such as
#' \code{readr::read_csv}. Note that this endpoint has been producing SSL errors. The \code{httr::GET()} request is wrapped in a \code{purrr::safely()} to get binary response when the request fails.
#'
#' @param report_name character. The name of the report. It should have the format REPORT_OWNER/REPORT_NAME you will need to pass the full string in.
#' @param organization character. The Workday organization. To find yours go to your Workday home page, the organization name is in the ulr \code{https://wd5.myworkday.com/ORGANIZATION_NAME/d/home.htmld}
#' @param username character. The username of the user who has access to the report.
#' @param password character. The password of the user who has access to the report.
#' @param params list. URL parameters to send into \code{httr::GET()}. Defaults to \code{list(format='csv')}. Common params include \code{list(Effective_as_of_date='2018-10-01-07:00')}.
#' @param return_format what format should you get the \code{GET()} response back as? Defaults to \code{"binary"}. Options are \code{"binary"} or \code{"http_response"}. If you get back the binary you can pass into \code{readr::read_*} to parse the data.
#' @param ... parameters to pass into \code{httr::GET()}.
#'
#' @import dplyr
#'
#' @export
get_workday_report <- function(
   report_name
  ,organization
  ,username
  ,password
  ,params = list(format = 'csv')
  ,return_format = 'binary'
  ,url_params = NULL
  ,...
) {

  if (!missing(url_params)) {
    warning("argument url_params is deprecated and now ignored; please use params instead.", call. = FALSE)
  }

  # create url
  endpoint <- 'https://wd5-services1.myworkday.com/ccx/service/customreport2/'
  query_url <- paste0(
      endpoint
    , organization
    , "/"
    , report_name
  )

  # Note there is some error that gets thrown here all the time. Its very annoying.
  # We will wrap in purr::safely() in order to mitigate an error that might occur
  # And stream the data back into a data object

  stream_response_back <- function(query_url, username, password, params) {
    workday_response <- httr::GET(
      url = query_url,
      httr::authenticate(user = username, password = password),
      query = params,
      httr::write_stream(function(x){
        report_data <<- c(x, report_data)
      }),
      ...
    )

    return(workday_response)
  }

  safe_stream_response <- purrr::safely(
      stream_response_back
    , otherwise = NA
    , quiet = F
  )

  report_data <- NULL
  get_response <- safe_stream_response(query_url, username, password, params)

  if(!is.null(get_response$error)) {
    warning("httr::GET resulted in an error and did not return desired output. Use return_format='binary' to safely get binary response. Error was printed in console")
  }

  if(return_format == 'binary') {
    return(report_data)
  } else if(return_format == 'http_response') {
    return(get_response$result)
  }
}

