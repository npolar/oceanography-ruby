require "oceanography/mapping/climate_forecast_mapper"

describe Oceanography::ClimateForecast do
  describe "#map" do
    subject(:cf_mapper) { Oceanography::ClimateForecast }

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
      expect(cf_mapper.map({"p" => 0})).to have_key("sea_water_pressure")
    end

    it "should use 'sea_water_pressure' for 'pres'" do
      expect(cf_mapper.map({"pres" => 0})).to have_key("sea_water_pressure")
    end

    it "should use 'sea_water_pressure' for 'pressure'" do
      expect(cf_mapper.map({"pressure" => 0})).to have_key("sea_water_pressure")
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

  end
end
