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

class Adms < Test::Unit::TestCase

	def do_xslt(data)
		xslt = XML::XSLT.new()
		xslt.xml = data
		xslt.xsl = "../genericode2adms.xsl"
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

	def test_asset
		out = do_xslt("data/test.gc")
		graph = parse_rdf(out)
		
		query = RDF::Query.new({
			:asset => {
				RDF.type => RDF::URI("http://www.w3.org/ns/adms#SemanticAsset"),
				RDF::URI("http://www.w3.org/ns/adms#identifier") => :id,
				RDF::RDFS.label => :label,
				RDF::URI("http://www.w3.org/ns/rad#version") => :version,
				RDF::DC.description => :description,
			}
		})
		
		result = query.execute(graph)[0]
		
		assert_equal result.id, "http://doesnotexist.local/ABC-1.0"
		assert_equal result.label, "TestCode"
		assert_equal result.version, "1.0"
		assert_equal result.description, "ABC Codelist TestCode 1.0"
	end
	
	def test_items
		out = do_xslt("data/test.gc")
		graph = parse_rdf(out)
		
		query = RDF::Query.new({
			:item => {
				RDF.type => RDF::URI("http://www.w3.org/ns/adms#Item"),
				RDF::RDFS.label => :label,
				RDF::DC.description => :description,
			}
		})
		
		result = query.execute(graph)
		assert_equal result.count, 2
		
		assert_equal result[0].label, "Code1"
		assert_equal result[0].description, "First Code"
		
		assert_equal result[1].label, "Code2"
		assert_equal result[1].description, "Second Code"
	end
	
end
