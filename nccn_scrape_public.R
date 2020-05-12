
# THIS SCRIPT REQUIRES THAT YOU HAVE THE CHROME BROWSER

if (!require(RSelenium)) install.packages('RSelenium')
if (!require(XML)) install.packages('XML')

require(RSelenium)
require(XML)

setwd("") # set your working directory here

# setup Selenium server
rem_dr <- rsDriver(verbose = FALSE, browser = "firefox")
rd <- rem_dr$client

# put your username and password here
username = "your username"
password = "your password"

# fill out log in page and submit
rd$navigate("https://www.nccn.org/professionals/biomarkers/content/")
rd$findElement("name", "ctl00$ctl00$MainContent$Center$txtEmail")$sendKeysToElement(list(username))
rd$findElement("name", "ctl00$ctl00$MainContent$Center$txtPassword")$sendKeysToElement(list(password))
rd$findElement("name", "ctl00$ctl00$MainContent$Center$btnLogin")$clickElement()
Sys.sleep(30) #give site a minute while we log in

# show all records and columns
rd$findElement("id", "btnShowAll")$clickElement()
Sys.sleep(60) #wait 1 minute to allow site to fetch results

# find number of entries
result_info   <- rd$findElement("id", "results_info")$getElementText()[[1]]
n_entries     <- substr(result_info, 20, nchar(result_info) - 8)
n_entries     <- as.numeric(gsub(",", "", n_entries))
n_pages       <- ceiling(n_entries / 10)
current_page  <- 1

# create blank data frame to put data in
results <- data.frame(disease_description = character(),
                      molecular_abnormality = character(),
                      gene_symbol = character(),
                      NCCN_evidence_level = character(),
                      NCCN_recommendation = character(),
                      stringsAsFactors = FALSE)

# collect data from each page in sequence
while(current_page <= n_pages){
    doc <- htmlParse(rd$getPageSource()[[1]]) # grab table from website
    temp_table <- readHTMLTable(doc, stringsAsFactors = FALSE) # make data frame from HTML table
    temp_table <- temp_table$results[,2:6] # drop useless first column
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
    Sys.sleep(5) # pause so we don't get blocked by server
}

# save data frame as CSV
write.csv(results, paste("nccn_biomarker_compendium_", Sys.Date(), ".csv", sep=""))

# close Selenium server
rd$close()
rem_dr$server$stop()
