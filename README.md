[![Build Status](https://travis-ci.org/npolar/oceanography-ruby.svg?branch=master)](https://travis-ci.org/npolar/oceanography-ruby) [![Code Climate](https://codeclimate.com/github/npolar/oceanography-ruby/badges/gpa.svg)](https://codeclimate.com/github/npolar/oceanography-ruby) [![Test Coverage](https://codeclimate.com/github/npolar/oceanography-ruby/badges/coverage.svg)](https://codeclimate.com/github/npolar/oceanography-ruby)

# oceanography-ruby

## Features
* Scan for netCDF files recursivly
* Parse each measurement to a json document
* Key mapping to standardize naming
* Complies with Climate and Forecast netCDF conventions where possible
* Validate json documents against schema
* Write documents to file or POST to document database
* Track parsed source files to source API
* Track rejected files to STDOUT

## Usage
You need netcdf c lib installed.
`sudo apt-get install libnetcdf-dev`

    Usage: ./ncdocs.sh [options] FILE|PATH
    -m, --mappers LIST               List of mappers to use, Default MissingValuesMapper,KeyValueCorrectionsMapper,
                                     CommentsMapper,CollectionMapper,ClimateForecastMapper
    -o, --outpath PATH               Path to write json docs to
    -p, --post URL                   URL to post json docs to
    -s, --schema PATH                Path to json schema to validate docs against
    -t, --threads #                  Number of threads. Default 4
    -v, --verbose                    Log level debug. Default info
    -h, --help                       Display this screen


## Contribute
Clone, `bundle install`, `bundle exec rspec`  
Please use feature branches.
