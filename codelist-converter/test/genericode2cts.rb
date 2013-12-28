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
require 'xml'
require 'xml/xslt'

class Cts < Test::Unit::TestCase

	def do_xslt(data, stylesheet)
		xslt = XML::XSLT.new()
		xslt.xml = data
		xslt.xsl = stylesheet
		xslt.parameters = { "canonicalUri" => "http://doesnotexist.local/", "renderUri" => "http://doesnotexist.local/", "accessDate" => "2013-12-31T21:38:00+01:00" }
		return xslt.serve;
	end

	def do_xslt_list(data, version)
		return do_xslt(data, "../genericode2cts" + version.sub(/\./, "") + "-entitylist.xsl")
	end

	def do_xslt_directory(data, version)
		return do_xslt(data, "../genericode2cts" + version.sub(/\./, "") + "-entitydirectory.xsl")
	end

	def do_list_validate(version)
		out = do_xslt_list("data/test.gc", version)
		result = XML::Document.string(out)

		xsd = XML::Document.file("../../vendor/cts2-" + version + "/entity/Entity.xsd")
		schema = XML::Schema.document(xsd)

		result.validate_schema(schema)
	end

	def do_directory_validate(version)
		out = do_xslt_directory("data/test.gc", version)
		result = XML::Document.string(out)

		xsd = XML::Document.file("../../vendor/cts2-" + version + "/entity/Entity.xsd")
		schema = XML::Schema.document(xsd)

		result.validate_schema(schema)
	end

	def test_cts11_directory_validate
		do_directory_validate("1.1")
	end

	def test_cts11_list_validate
		do_list_validate("1.1")
	end

	def test_cts10_directory_validate
		do_directory_validate("1.0")
	end

	def test_cts10_list_validate
		do_list_validate("1.0")
	end

	def do_directory_entities(version, namespaces)
		out = do_xslt_directory("data/test.gc", version)

		result = XML::Document.string(out)
		
		date = result.find("//cts-core:accessDate", namespaces)
		assert_equal date.count, 1
		assert_equal date.first.content, "2013-12-31T21:38:00+01:00"
		
		entities = result.find("//cts:entry", namespaces)
		assert_equal entities.count, 2
		
		name = result.find("//cts:entry[1]/@about", namespaces)
		assert_equal name.count, 1
		assert_equal name.first.value, "http://doesnotexist.local/ABC-1.0/Code1"
		
		name = result.find("//cts:entry[1]/@href", namespaces)
		assert_equal name.count, 1
		assert_equal name.first.value, "http://doesnotexist.local/codesystem/TestCode/version/1.0/entity/Code1"
		
		name = result.find("//cts:entry[2]/@about", namespaces)
		assert_equal name.count, 1
		assert_equal name.first.value, "http://doesnotexist.local/ABC-1.0/Code2"
		
		name = result.find("//cts:entry[2]/@href", namespaces)
		assert_equal name.count, 1
		assert_equal name.first.value, "http://doesnotexist.local/codesystem/TestCode/version/1.0/entity/Code2"
		
		name = result.find("//cts:entry[1]/cts-core:name", namespaces)
		assert_equal name.count, 1
		
		assert_equal name.first.children[0].content, "bii"
		assert_equal name.first.children[1].content, "Code1"
		
		name = result.find("//cts:entry[2]/cts-core:name", namespaces)
		assert_equal name.count, 1
		
		assert_equal name.first.children[0].content, "bii"
		assert_equal name.first.children[1].content, "Code2"
		
		name = result.find("//cts:entry[1]/cts-core:knownEntityDescription", namespaces)
		assert_equal name.count, 1
		assert_equal name.first.children[0].children[0].content, "1.0"
		assert_equal name.first.children[0].children[1].content, "TestCode"
		assert_equal name.first.children[1].content, "First Code"
		
		name = result.find("//cts:entry[2]/cts-core:knownEntityDescription", namespaces)
		assert_equal name.count, 1
		assert_equal name.first.children[0].children[0].content, "1.0"
		assert_equal name.first.children[0].children[1].content, "TestCode"
		assert_equal name.first.children[1].content, "Second Code"
	end
	
	def test_cts10_directory_entities
		namespaces = [
			'cts:http://schema.omg.org/spec/CTS2/1.0/Entity',
			'cts-core:http://schema.omg.org/spec/CTS2/1.0/Core'
		]
		do_directory_entities("1.0", namespaces)
	end
	
	def test_cts11_directory_entities
		namespaces = [
			'cts:http://www.omg.org/spec/CTS2/1.1/Entity',
			'cts-core:http://www.omg.org/spec/CTS2/1.1/Core'
		]
		do_directory_entities("1.1", namespaces)
	end
	
end
