require "spec_helper"
require "oceanography/mapping/ods_climate_forecast_mapper"

describe Oceanography::ODSClimateForecastMapper do
  describe "#map" do
    subject(:cf_mapper) { Oceanography::ODSClimateForecastMapper.new }

    it "should use 'sea_water_temperature' for 't'" do
      expect(cf_mapper.map({"t" => 0})).to have_key("sea_water_temperature")
    end

    it "should use 'sea_water_temperature' for 'temp'" do
      expect(cf_mapper.map({"temp" => 0})).to have_key("sea_water_temperature")
    end

    it "should use 'sea_water_temperature' for 'temperature'" do
      expect(cf_mapper.map({"temperature" => 0})).to have_key("sea_water_temperature")
    end

    it "should use 'sea_water_pressure' for 'p'" do
      expect(cf_mapper.map({"p" => 0})).to have_key("sea_water_pressure_due_to_sea_water")
    end

    it "should use 'sea_water_pressure' for 'pres'" do
      expect(cf_mapper.map({"pres" => 0})).to have_key("sea_water_pressure_due_to_sea_water")
    end

    it "should use 'sea_water_pressure' for 'pressure'" do
      expect(cf_mapper.map({"pressure" => 0})).to have_key("sea_water_pressure_due_to_sea_water")
    end

    it "should use 'sea_water_salinity' for 's'" do
      expect(cf_mapper.map({"s" => 0})).to have_key("sea_water_salinity")
    end

    it "should use 'sea_water_salinity' for 'salinity'" do
      expect(cf_mapper.map({"salinity" => 0})).to have_key("sea_water_salinity")
    end

    it "should use 'direction_of_sea_water_velocity' for 'dire'" do
      expect(cf_mapper.map({"dire" => 0})).to have_key("direction_of_sea_water_velocity")
    end

    it "should use 'eastward_sea_water_velocity' for 'uvel'" do
      expect(cf_mapper.map({"uvel" => 0})).to have_key("eastward_sea_water_velocity")
    end

    it "should use 'northward_sea_water_velocity' for 'vvel'" do
      expect(cf_mapper.map({"vvel" => 0})).to have_key("northward_sea_water_velocity")
    end

    it "should use 'sea_water_electrical_conductivity' for 'conductivity'" do
      expect(cf_mapper.map({"conductivity" => 0})).to have_key("sea_water_electrical_conductivity")
    end

    it "should use 'sea_floor_depth_below_sea_surface' for 'water_depth'" do
      expect(cf_mapper.map({"water_depth" => nil})).to have_key("sea_floor_depth_below_sea_surface")
    end

    it "should use 'sea_floor_depth_below_sea_surface' for 'echo_depth'" do
      expect(cf_mapper.map({"echo_depth" => nil})).to have_key("sea_floor_depth_below_sea_surface")
    end

    it "should use 'depth' for 'dept'" do
      expect(cf_mapper.map({"dept" => nil})).to have_key("depth")
    end

    it "should use 'depth' for 'instrdepth'" do
      expect(cf_mapper.map({"instrdepth" => nil})).to have_key("depth")
    end

    it "should convert cm/s to m/s" do
      expect(cf_mapper.map({"a" => 100}, {"variables" => [{"name" => "a", "units" => "cm/s"}]})["a"]).to eq(1)
    end

    it "should not produce unit conversions with more that 5 decimal points" do
      expect(cf_mapper.map({"a" => 10.12345}, {"variables" => [{"name" => "a", "units" => "cm/s"}]})["a"]).to eq(0.10123)
    end

  end
end
