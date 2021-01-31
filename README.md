# Scraping the NCCN Biomarker Compendium

The [NCCN Biomarker Compendium](https://www.nccn.org/professionals/biomarkers/content/) is a collection of cancer biomarkers organized by indication, test, mutation, and level of evidence. This software allows the user to scrape it in its entirety and deposit the compendium into a CSV file. 

## Prerequisites

This script assumes that you have an NCCN account and that the Firefox browser is installed on your computer. If you use a browser other than Firefox [see here](https://cran.r-project.org/web/packages/RSelenium/vignettes/RSelenium-basics.html#rsdriver) for a note on how to use alternative browsers with RSelenium.

## Built With

* [Selenium](http://www.seleniumhq.org/) - Browser driver
* [RSelenium](https://cran.r-project.org/web/packages/RSelenium/vignettes/RSelenium-basics.html) - Selenium interface for R

## Note on results

Starting January 2021, the NCCN website began including links to "Read more" / "Read less" for some fields. This algorithm accommodates these changes, but includes "Read less" at the end of some fields.

## Authors

* **Nathaniel Hendrix** - [My Website](https://nathanielhendrix.com)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details


