
# THIS SCRIPT REQUIRES THAT YOU HAVE THE FIREFOX BROWSER

if (!require(RSelenium)) install.packages('RSelenium')
if (!require(XML)) install.packages('XML')

require(RSelenium)
require(XML)
require(stringr)

setwd("D:/ndhen/Dropbox/Primer/PRIMER_DIFFUSION MODEL/NCCN biomarker compendium scrape") #desktop
#setwd("~/Dropbox (UW)/Primer/PRIMER_DIFFUSION MODEL/NCCN biomarker compendium scrape") #laptop

# setup Selenium server
rem_dr <- rsDriver(verbose = FALSE, browser = "firefox")
rd <- rem_dr$client

# fill out log in page and submit
rd$navigate("https://www.nccn.org/professionals/biomarkers/content/")
rd$findElement("name", "ctl00$ctl00$MainContent$Center$txtEmail")$sendKeysToElement(list("nhendrix@uw.edu"))
rd$findElement("name", "ctl00$ctl00$MainContent$Center$txtPassword")$sendKeysToElement(list("Ky!@l5ysv2E0s$M"))
rd$findElement("name", "ctl00$ctl00$MainContent$Center$btnLogin")$clickElement()
Sys.sleep(10) #give site a minute while we log in

# # show all records and columns
# rd$findElement("id", "btnShowAll")$clickElement()
# Sys.sleep(60) #wait 1 minute to allow site to fetch results

# create blank data frame to put data in
results <- data.frame(disease_description = character(),
                      molecular_abnormality = character(),
                      gene_symbol = character(),
                      NCCN_evidence_level = character(),
                      NCCN_recommendation = character(),
                      stringsAsFactors = FALSE)

# get list of gene options
dd <- rd$findElement("id", "ddlGuideline")
disease_html <- dd$getElementAttribute("outerHTML")[[1]]
diseases <- htmlParse(disease_html)
diseases <- unlist(diseases["//option", fun = function(x) xmlGetAttr(x, "value")])
diseases <- diseases[2:length(diseases)]

# go through list of genes to get 
for(d in diseases) {
  
  # query database
  option <- rd$findElement(using = "xpath", 
                 paste0("//select[@id='ddlGuideline']/option[@value='", d, "']"))
  option$clickElement()
  Sys.sleep(5) # give it a second to retrieve results
  
  # click all 'read more'
  read_more <- function() {
    out <- tryCatch(
      {
        read_more <- rd$findElements("class", "rm-link")
        read_more <- unlist(lapply(read_more, function(x) x$getElementAttribute("id")))
        for(r in 1:length(read_more)) {
          rm_temp <- rd$findElement(using = "id", read_more[r])
          rm_temp$clickElement()
        }
      },
      error = function(cond){
        print("")
      }
    )
  }
  read_more()
  
  # find number of entries
  result_info   <- rd$findElement("id", "searchResults_info")$getElementText()[[1]]
  entry_start   <- str_locate(result_info, "Showing 1 to ")[2]
  entry_end     <- str_locate(result_info, " of ")[1]
  total_start   <- str_locate(result_info, " of ")[2]
  total_end     <- str_locate(result_info, " entries")[1]
  n_entries     <- substr(result_info, entry_start + 1, entry_end - 1)
  n_entries     <- as.numeric(gsub(",", "", n_entries))
  n_pages       <- ceiling(n_entries / as.numeric(substr(result_info, total_start + 1, total_end - 1)))
  current_page  <- 1
  
  # collect data from each page in sequence
  while(current_page <= n_pages){
    doc <- htmlParse(rd$getPageSource()[[1]]) # grab table from website
    temp_table <- readHTMLTable(doc, stringsAsFactors = FALSE) # make data frame from HTML table
    temp_table <- temp_table$searchResults[,3:7] # drop useless first column
    colnames(temp_table) = c("disease_description", #rename elements to match results df above
                             "molecular_abnormality",
                             "gene_symbol",
                             "NCCN_evidence_level",
                             "NCCN_recommenation")
    results <- rbind(results, temp_table) # combine this page's table with previous pages'
    if(current_page < n_pages) {
      rd$findElement("id", "results_next")$clickElement() # go to next page
    }
    current_page = current_page + 1 # iterate current page number
    Sys.sleep(1) # pause so we don't get blocked by server
  }
}

# save data frame as CSV
write.csv(results, paste("nccn_biomarker_compendium_", Sys.Date(), ".csv", sep=""))

# close Selenium server
rd$close()
rem_dr$server$stop()
