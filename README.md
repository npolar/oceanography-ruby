[![Code Climate](https://codeclimate.com/github/npolar/oceanography-ruby/badges/gpa.svg)](https://codeclimate.com/github/npolar/oceanography-ruby) [![Test Coverage](https://codeclimate.com/github/npolar/oceanography-ruby/badges/coverage.svg)](https://codeclimate.com/github/npolar/oceanography-ruby)

# oceanography-ruby

## Features
* Scan for netCDF files recursivly
* Parse each measurement to a json document
* Key mapping to standardize naming
* Complies with Climate and Forecast netCDF conventions where possible
* Validate json documents against schema
* Write documents to file or POST to document database

## Usage
    Usage: ./ncdocs.sh [options] PATH [DOCDB_URL] 
    If DOCDB_URL is given json documents will be PUT to that URL iff all documents are valid.

    -m, --mappers LIST               List of mappers to use, Default MissingValuesMapper,KeyValueCorrectionsMapper,
                                     CommentsMapper,CollectionMapper,ClimateForecastMapper
    -o, --outpath PATH               Path to write json docs to.
    -s, --schema PATH                Path to json schema to validate docs against
    -v, --verbose                    Log level debug. Default info
    -h, --help                       Display this screen

## Contribute
Clone, bundle install, rspec 
Please use feature branches.
