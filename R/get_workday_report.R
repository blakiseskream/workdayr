#' @title Retrieve a report via the Workday RaaS
#'
#' @description
#' Query's the Workday Report As a Service API. A tutorial on how to use this API is located \href{https://docs.workato.com/connectors/workday/workday_raas.html}{here}
#' This function specifically uses \code{httr::GET(httr::write_disk())} to return the result as a file_path to the saved report.
#' After you get the response you can use a \code{readr} function to read the result such as \code{readr::read_csv}.
#' Note that this endpoint has been producing SSL errors. The \code{httr::GET()} request is wrapped in a \code{purrr::safely()} to write the file to disk regardless of error.
#'
#' @param report_name character. The name of the report. It should have the format REPORT_OWNER/REPORT_NAME you will need to pass the full string in.
#' @param organization character. The Workday organization. To find yours go to your Workday home page, the organization name is in the ulr \code{https://wd5.myworkday.com/ORGANIZATION_NAME/d/home.htmld}
#' @param username character. The username of the user who has access to the report.
#' @param password character. The password of the user who has access to the report.
#' @param params list. URL parameters to send into \code{httr::GET()}. Defaults to \code{list(format='csv')}. Common params include \code{list(Effective_as_of_date='2018-10-01-07:00')}.
#' @param file_path where should the report be saved? Defaults to \code{tempfile()}.
#' @param overwrite boolean. Should the be overwritten? Defaults to \code{TRUE}.
#' @param url_params Deprecated use params.
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
  ,file_path = tempfile()
  ,overwrite = TRUE
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

  stream_response_back <- function(query_url, username, password, params, file_path, overwrite) {

    workday_response <- httr::GET(
      url = query_url,
      httr::authenticate(user = username, password = password),
      query = params,
      httr::write_disk(file_path, overwrite),
      ...
    )

    return(workday_response)
  }

  safe_stream_response <- purrr::safely(
      stream_response_back
    , otherwise = NA
    , quiet = F
  )

  get_response <- safe_stream_response(query_url, username, password, params, file_path, overwrite)

  if(!is.null(get_response$error)) {
    warning("httr::GET resulted in an error and did not return desired output. Check file path for the specific output. Error was printed in console")
  }

  return(file_path)
}

