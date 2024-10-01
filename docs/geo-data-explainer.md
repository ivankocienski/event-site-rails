# Geo Data 

ESR relies on data from the UK ONS to make the "location of address" browsing part of the site functional.

This document explains how this data is prepared and loaded.

## Outline of procedure
- Download ONS data set
- Modify preparation script
- Run preperation script
- (Load partner and event data into database
- Run rake task that connects postcodes to geo enclosures

## Getting the data

This data is downloaded from the [ONS portal](https://geoportal.statistics.gov.uk/datasets/73ce619853044aaaa6f7fa5b90765b85/about).

It has a name like "National Statistics Postcode Lookup - 2021 Census (August 2024) for the UK" or `PRD_NSPL AUG_2024`.

Unzip this into a folder in the `tmp/` directory like `tmp/ons-nspl-aug-2024/` or similar.

## Modifying the preperation script

Unfortunately these data sets don't follow any formal format and are just a collection of CSVs so each data set must be loaded by a specific script. You may get lucky and the script "just works" but maybe not, so...

Open `hacks/parsing-postcode-data.rb` (You may want to copy it for the dataset you have downloaded).

## Running the preperation script

TBC: Should be as easy as `ruby hacks/parsing-postcode-data.rb`. It will generate an output JSON file that can be commited in the repo.

## Running the rake task

TBC: Once the script is loaded 


## What the hecc is this anyhow?

