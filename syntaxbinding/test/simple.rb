#!/usr/bin/ruby

# The MIT License (MIT)
#
# Copyright (c) 2013 Veit Jahns
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

require 'test/unit'
require 'xml/xslt'

class Property < Test::Unit::TestCase

	def do_xslt(data)
		xslt = XML::XSLT.new()
		xslt.xml = data
		xslt.xsl = "../syntaxbinding.xsl"
		xslt.parameters = { "root" => "ROOT",
		                    "ontology-file" => "test/data/ontology.rdf" }
		return xslt.serve;
	end
	
	def assert_id_only(result)
		tokens = result.split(/[;\n]/)
		
		assert_equal result.lines.count, 1
		
		assert_equal tokens[0], "bii:tir19-001-Id"
		assert_equal tokens[1], "http://spec.cenbii.eu/BII2#tir19-Class"
		assert_equal tokens[2], "/ROOT/ELEMENT_CONCEPT/ELEMENT_PROPERTY"
	end
	
	def assert_id_name(result)
		tokens = result.split(/[;\n]/)
		
		assert_equal result.lines.count, 2
		
		assert_equal tokens[0], "bii:tir19-001-Id"
		assert_equal tokens[1], "http://spec.cenbii.eu/BII2#tir19-Class"
		assert_equal tokens[2], "/ROOT/ELEMENT_CONCEPT/ELEMENT_PROPERTY_1"
		
		assert_equal tokens[3], "bii:tir19-002-Name"
		assert_equal tokens[4], "http://spec.cenbii.eu/BII2#tir19-Class"
		assert_equal tokens[5], "/ROOT/ELEMENT_CONCEPT/ELEMENT_PROPERTY_2"
	end
	
	def test_property_reference
		out = do_xslt("data/property_reference.xsd")
		assert_id_only(out)
	end
	
	def test_property_noreference
		out = do_xslt("data/property_noreference.xsd")
		assert_id_only(out)
	end
	
	def test_property_two
		out = do_xslt("data/property_two.xsd")
		assert_id_name(out)
	end
	
	def test_property_type_noreference
		out = do_xslt("data/property_type_noreference.xsd")
		assert_id_only(out);
	end
	
	def test_property_type_reference
		out = do_xslt("data/property_type_reference.xsd")
		assert_id_only(out);
	end
end
