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

	def assert_attribute(document, xpath, namespaces, value)
		object = document.find(xpath, namespaces)
		assert_equal object.count, 1
		assert_equal object.first.value, value
	end
	
	def assert_text_node(document, xpath, namespaces, value)
		object = document.find(xpath, namespaces)
		assert_equal object.count, 1
		assert_equal object.first.content, value
	end
	
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

	def do_xslt_codesystem(data, version)
		return do_xslt(data, "../genericode2cts" + version.sub(/\./, "") + "-codesystem.xsl")
	end
	
	def do_codesystem_validate(version)
		out = do_xslt_codesystem("data/test.gc", version)
		result = XML::Document.string(out)

		xsd = XML::Document.file("../../vendor/cts2-" + version + "/codesystem/CodeSystem.xsd")
		schema = XML::Schema.document(xsd)
		
		result.validate_schema(schema)
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
		
		do_assert_heading(result, namespaces, "codesystem/TestCode/version/1.0/entities")
		
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
	
	def do_assert_heading(document, namespaces, uri)
		assert_text_node(
			document,
			"/*/cts-core:heading/cts-core:resourceRoot",
			namespaces,
			"http://doesnotexist.local/")
		assert_text_node(
			document,
			"/*/cts-core:heading/cts-core:resourceURI",
			namespaces,
			uri)
		assert_text_node(
			document,
			"/*/cts-core:heading/cts-core:accessDate",
			namespaces,
			"2013-12-31T21:38:00+01:00")
	end
	
	def do_codesystem(version, namespaces)
		out = do_xslt_codesystem("data/test.gc", version)
		result = XML::Document.string(out)
		
		do_assert_heading(result, namespaces, "codesystem/TestCode")
		
		if version == "1.0"
			entry = "CodeSystemCatalogEntry"
		else
			entry = "codeSystemCatalogEntry"
		end
		
		entities = result.find("//cts:" + entry, namespaces)
		assert_equal entities.count, 1
		
		assert_attribute(
			result,
			"/cts:CodeSystemCatalogEntryMsg/cts:" + entry + "/@about",
			namespaces,
			"http://doesnotexist.local/ABC")
					
		assert_attribute(
			result,
			"/cts:CodeSystemCatalogEntryMsg/cts:" + entry + "/@codeSystemName",
			namespaces,
			"TestCode")
			
		assert_text_node(
			result,
			"/cts:CodeSystemCatalogEntryMsg/cts:" + entry + "/cts:versions",
			namespaces,
			"codesystem/TestCode/versions")
			
		assert_text_node(
			result,
			"/cts:CodeSystemCatalogEntryMsg/cts:" + entry + "/cts:currentVersion/cts-core:version",
			namespaces,
			"1.0")
			
		assert_attribute(
			result,
			"/cts:CodeSystemCatalogEntryMsg/cts:" + entry + "/cts:currentVersion/cts-core:version/@uri",
			namespaces,
			"http://doesnotexist.local/ABC-1.0")
			
		assert_attribute(
			result,
			"/cts:CodeSystemCatalogEntryMsg/cts:" + entry + "/cts:currentVersion/cts-core:version/@href",
			namespaces,
			"http://doesnotexist.local/codesystem/TestCode/version/1.0")
			
		assert_text_node(
			result,
			"/cts:CodeSystemCatalogEntryMsg/cts:" + entry + "/cts:currentVersion/cts-core:codeSystem",
			namespaces,
			"TestCode")
			
		assert_attribute(
			result,
			"/cts:CodeSystemCatalogEntryMsg/cts:" + entry + "/cts:currentVersion/cts-core:codeSystem/@uri",
			namespaces,
			"http://doesnotexist.local/ABC")
			
		assert_attribute(
			result,
			"/cts:CodeSystemCatalogEntryMsg/cts:" + entry + "/cts:currentVersion/cts-core:codeSystem/@href",
			namespaces,
			"http://doesnotexist.local/codesystem/TestCode")
	end
	
	def test_cts10_codesystem
		namespaces = [
			'cts:http://schema.omg.org/spec/CTS2/1.0/CodeSystem',
			'cts-core:http://schema.omg.org/spec/CTS2/1.0/Core'
		]
		do_codesystem("1.0", namespaces)
	end
	
	def test_cts11_codesystem
		namespaces = [
			'cts:http://www.omg.org/spec/CTS2/1.1/CodeSystem',
			'cts-core:http://www.omg.org/spec/CTS2/1.1/Core'
		]
		do_codesystem("1.1", namespaces)
	end
	
	def test_cts10_codesystem_validate
		do_codesystem_validate("1.0")
	end
	
	def test_cts10_codesystem_validate
		do_codesystem_validate("1.1")
	end
end
