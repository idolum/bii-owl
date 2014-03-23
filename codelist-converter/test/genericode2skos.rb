#!/usr/bin/ruby

# The MIT License (MIT)
#
# Copyright (c) 2013-2014 Veit Jahns
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
require 'rdf'
require 'rdf/raptor'
require 'rest-client'
require 'open-uri'

class Skos < Test::Unit::TestCase

	def do_xslt(data)
		xslt = XML::XSLT.new()
		xslt.xml = data
		xslt.xsl = "../genericode2skos.xsl"
		xslt.parameters = { "canonicalUri" => "http://doesnotexist.local/" }
		return xslt.serve;
	end
	
	def parse_rdf(data)
		graph = RDF::Graph.new
		RDF::Reader.for(:file_extension => "rdf").new(data) do |reader|
			reader.each_statement do |statement|
				graph << statement
			end
		end
		return graph
	end
	
	def validate_skos(text)
		response =
			RestClient.post(
				"http://www.w3.org/RDF/Validator/rdfval",
				"RDF=" + URI::encode(text) + "&PARSE=Parse%20RDF",
				:content_type => "application/x-www-form-urlencoded")
		result = response.to_str
		
		if result =~/<h3>Error Messages<\/h3>/
			result.scan(/Error:[^<]*/) { |m|
				assert false, "#{m}"
			}			
		end
	end
	
	def assert_literal_equal(literal, value, language)
		if literal.plain?
			assert_equal literal, value
		else
			assert_equal literal.value, value
			assert_equal literal.language, language
		end
	end
	
	def assert_uri_equal(uri, value)
		assert_equal uri.to_s, value
	end

	def test_asset
		out = do_xslt("data/test.gc")
		graph = parse_rdf(out)
		
		query = RDF::Query.new({
			:asset => {
				RDF.type => RDF::URI("http://www.w3.org/2004/02/skos/core#ConceptScheme"),
				RDF::RDFS.label => :label
			}
		})
		
		result = query.execute(graph)[0]
		
		assert_literal_equal result.label, "TestCode", :en
	end
	
	def test_items
		out = do_xslt("data/test.gc")
		validate_skos(out)
		graph = parse_rdf(out)
		
		query = RDF::Query.new({
			:item => {
				RDF.type => RDF::URI("http://www.w3.org/2004/02/skos/core#Concept"),
				RDF::RDFS.label => :label,
				RDF::SKOS.inScheme => :inScheme,
				RDF::SKOS.notation => :notation,
				RDF::SKOS.prefLabel => :prefLabel
			}
		})
		
		result = query.execute(graph)
		assert_equal result.count, 2
		
		assert_equal result[0].notation, "Code1"
		assert_literal_equal result[0].label, "First Code", :en
		assert_uri_equal result[0].inScheme, "http://doesnotexist.local/ABC-1.0"
		
		assert_equal result[1].notation, "Code2"
		assert_literal_equal result[1].prefLabel, "Second Code", :en
		assert_uri_equal result[0].inScheme, "http://doesnotexist.local/ABC-1.0"
	end
	
end
