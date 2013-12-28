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
		xslt.parameters = { "canonicalUri" => "http://doesnotexist.local/", "renderUri" => "http://doesnotexist.local/" }
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


end
