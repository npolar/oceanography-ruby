require "spec_helper"

require "oceanography/netcdf"
require "oceanography/ncml"

describe Oceanography::NetCDF do

  EPSILON = 1.0e-13 # Required precision for floats

  context "Real data" do
    _data = "#{__dir__}/_data"
    Dir["#{_data}/**/*.cdl"].sort.each {|f|

      context f.gsub(_data, "") do

        before do
          nc_filename = f.gsub(/cdl/, "nc")
          `ncgen -o #{nc_filename} #{f}`

          @netcdf = Oceanography::NetCDF.new
          @netcdf.open(nc_filename)

          ncdump_xml_filename = f.gsub(/cdl/, "xml")
          if not File.exists? ncdump_xml_filename
            `ncdump -x #{nc_filename} > #{ncdump_xml_filename}`
          end
          @ncml = Oceanography::NcML.new(ncdump_xml_filename)

          @expected = { "attributes" => @ncml.attributes,
            "dimensions" => @ncml.dimensions,
            "variables" => @ncml.variables }
        end

        #context "attributes" do
        #  it do
        #    #@netcdf.Mooring.should == 0
        #  end
        #end


        # @todo plugable?
        #context "sanity checks" do
        #  context "time" do
        #    # datatime(time).year should match file name for casts, for moorings +-2 years?
        #  end
        #
        #  context "variable size" do
        #     #expect(@netcdf.variable("time").size).to eq({})
        #  end
        #
        #  it do
        #    # expect(@netcdf.variables_metadata).to match(@expected["dimensions"])
        #  end
        #
        #end

        describe "#dimensions" do
          subject(:dimensions) { @netcdf.dimensions }

          it { expect(dimensions).to eq(@expected["dimensions"]) }

        end

        describe "#attributes" do
          subject(:attributes) { @netcdf.attributes }
          it "should return a Hash" do
            expect(attributes.class).to eq(Hash)
          end


          context "#keys" do
            it do
              expect(attributes.keys.sort).to eq(@expected["attributes"].keys.sort)
            end
          end

          # @todo [Array<Float|NaN>] matcher
          context "float attributes" do

            it "are all within #{EPSILON} of expected" do

              expected_float_attributes = @expected["attributes"].select {|k,v| v.respond_to?(:all?) and v.all? {|v| v.is_a? Float } }
              actual_float_attributes = @netcdf.attributes.select {|k,v| v.respond_to?(:all?) and v.all? {|v| v.is_a? Float } }

              actual_float_attributes.each do |k,v|

                v.each_with_index do |f,i|

                  if f.nan?
                    # @todo why is expected 0.0 for NaN's?
                    #expect(f).to eq(expected_float_attributes[k][i])
                  else
                    expect(f).to be_within(EPSILON).of(expected_float_attributes[k][i])
                  end
                end

              end

            end
          end

          # @todo [Array<Integer>] matcher
          context "integer attributes" do

            it "are all identical to expected" do

              expected_int_attributes = @expected["attributes"].select {|k,v| v.respond_to?(:all?) and v.all? {|v| v.is_a? Integer } }
              actual_int_attributes = @netcdf.attributes.select {|k,v| v.respond_to?(:all?) and v.all? {|v| v.is_a? Integer } }

              actual_int_attributes.each do |k,v|

                v.each_with_index do |integer,i|

                  expect(integer).to eq(expected_int_attributes[k][i])
                end

              end

            end
          end

          # @todo [Array<String>] matcher
          context "string attributes" do

            it "are all identical to expected" do

              expected_string_attributes = @expected["attributes"].select {|k,v| v.respond_to?(:all?) and v.all? {|v| v.is_a? String } }
              actual_string_attributes = @netcdf.attributes.select {|k,v| v.respond_to?(:all?) and v.all? {|v| v.is_a? String } }

              actual_string_attributes.each do |k,v|

                v.each_with_index do |string,i|
                  expect(string).to eq(expected_string_attributes[k][i])
                end

              end

            end
          end

        end

        #describe "#attribute" do
        #  it do
        #   #expect(@netcdf.variable("time").size).to eq({})
        #  end
        #end
        ## test magical method send(:attribute_name.to_sym)
        #
        #
        #describe "#variable" do
        #  it do
        #    #expect(@netcdf.variable("time").size).to eq({})
        #  end
        #end

        describe "#variables" do
          subject(:variables) { @netcdf.variables }

          it {

            # dimensions in ruby == shape in xml
            #expected: "time level lat lon" <-xml
            #got: [10, 5, 4, 1] <- ruby

            #expected: ["time", "level", "lat", "lon"] (shape <-xml)
            #got: ["lon", "lat", "level", "time"] (dimensions <- ruby)


            expect(variables.map {|v|v["dimensions"]}.first).to eq(@expected["variables"][0]["shape"])
            #@netcdf.variable("x") == @netcdf.send(:x)
          }




        end


        describe "#datetime" do
          #subject(:datetime) {  }

          it "Array of DateTime (or Exception if no time dimension)" do
            if @netcdf.dimensions.map {|d| d["name"] }.include? "time"
              expect(@netcdf.datetime.map {|dt| dt.class}.uniq).to eq([DateTime])
            else
              #expect(@netcdf.datetime).to raise_error(RuntimeError)
            end

          end

        end




      end # End _data context
    } # End _data loop

  end
end
