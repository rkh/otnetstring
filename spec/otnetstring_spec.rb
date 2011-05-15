# Based on tnetstring-rb's spec/tnetstring_spec.rb
#
# Copyright (c) 2011 Matt Yoho
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'otnetstring'

describe OTNetstring do
  context "parsing" do
    it "parses an integer" do
      OTNetstring.parse('5#12345').should == 12345
    end

    it "parses an empty string" do
      OTNetstring.parse('0,').should == ""
    end

    it "parses a string" do
      OTNetstring.parse('12,this is cool').should == "this is cool"
    end

    it "parses to an empty array" do
      OTNetstring.parse('0[').should == []
    end

    it "parses an arbitrary array of ints and strings" do
      OTNetstring.parse('21[5#123455#678905,xxxxx').should == [12345, 67890, 'xxxxx']
    end

    it "parses to an empty hash" do
      OTNetstring.parse('0{').should == {}
    end

    it "parses an arbitrary hash of ints, strings, and arrays" do
      OTNetstring.parse('30{5,hello20[11#123456789014,this').should == {"hello" => [12345678901, 'this']}
    end

    it "parses a null" do
      OTNetstring.parse('0~').should == nil
    end

    it "parses a boolean" do
      OTNetstring.parse('4!true!').should == true
    end

    it "raises an error if length is missing" do
      lambda {
        OTNetstring.parse('#123')
      }.should raise_error(OTNetstring::Error, "Expected '#' to be a digit")
    end

    it "raises an error if length is longer than 9 digits" do
      lambda {
        OTNetstring.parse('9' * 10 + ',')
      }.should raise_error(OTNetstring::Error, '9999999999 is longer than 9 digits')
    end
  end

  context "encoding" do
    it "encodes an integer" do
      OTNetstring.encode(42).should == "2#42"
    end

    it "encodes a string" do
      OTNetstring.encode("hello world").should == "11,hello world"
    end

    context "boolean" do
      it "encodes true as 'true'" do
        OTNetstring.encode(true).should == "4!true"
      end

      it "encodes false as 'false'" do
        OTNetstring.encode(false).should == "5!false"
      end
    end

    it "encodes nil" do
      OTNetstring.encode(nil).should == "0~"
    end

    context "arrays" do
      it "encodes an empty array" do
        OTNetstring.encode([]).should == "0["
      end

      it "encodes an array of arbitrary elements" do
        OTNetstring.encode(["cat", false, 123]).should == "17[3,cat5!false3#123"
      end

      it "encodes nested arrays" do
        OTNetstring.encode(["cat", [false, 123]]).should == "20[3,cat12[5!false3#123"
      end
    end

    context "hashes" do
      it "encodes an empty hash" do
        OTNetstring.encode({}).should == "0{"
      end

      it "encodes an arbitrary hash of primitives and arrays" do
        OTNetstring.encode({"hello" => [12345678901, 'this']}).should == '30{5,hello20[11#123456789014,this'
      end

      it "encodes nested hashes" do
        OTNetstring.encode({"hello" => {"world" => 42}}).should == '21{5,hello11{5,world2#42'
      end
    end

    it "rejects non-primitives" do
      expect { TNetstring.encode(Object.new) }.to raise_error
    end
  end
end
