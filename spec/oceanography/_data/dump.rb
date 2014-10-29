{
  "attributes" => {
    "time" => [1981,10,11,15,21,0],
    "station" => [1],
    "originalstation" => [403],
    "platform" => "unknown",
    "cruise" => "fs1981",
    "ctd" => "unknown",
    "INST_TYPE" => "ctd",
    "latitude" => [78.0],
    "longitude" => [12.5]
  },
  "variables" => [
    {
      "name" => "array",
      "type" => "float",
      "typecode" => 5,
      "shape" => [3],
      "total" => 3,
      "rank" => 1,
      "dimensions" => ["three"],
      "units" => "UTC in julian days since 0000-0-0 00:00:00",
      "long_name" => "time",
      "standard_name" => "time",
      "fillvalue" => "NaN"
    },
    {
      "name" => "max",
      "type" => "float",
      "typecode" => 5,
      "shape" => [2,3],
      "total" => 6,
      "rank" => 1,
      "dimensions" => ["two", "three"],
      "units" => "decibars",
      "long_name" => "in-situ pressure",
      "standard_name" => "pressure",
      "fillvalue" => "NaN"
    },
    {
      "name" => "one",
      "type" => "float",
      "typecode" => 5,
      "shape" => [1],
      "total" => 1,
      "rank" => 1,
      "dimensions" => ["one"],
      "units" => "decibars",
      "long_name" => "in-situ pressure",
      "standard_name" => "pressure",
      "fillvalue" => "NaN"
    }
  ],
  "dimensions" => [
    {
      "name" => "one",
      "length" => 1,
      "unlimited" => false
    },
    {
      "name" => "two",
      "length" => 2,
      "unlimited" => false
    },
    {
      "name" => "three",
      "length" => 3,
      "unlimited" => false
    }
  ],
  "metadata" => {
    "filename" => "/mnt/datasets/OceanographicDataStorage/data/framstrait/processed/casts/fs1981/001.nc",
    "sha1" => "6addf2f367bdf8e3d6970fee75748018571952f0"
  },
  "data" => {
    "one" => [[[[1]]]],
    "array" => [0, 1, 2],
    "max" => [[3, 4, 5], [6, 7, 8]]
  }
}
