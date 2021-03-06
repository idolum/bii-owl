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
	
	def assert_id_only_predicate(result)
		tokens = result.split(/[;\n]/)
		
		assert_equal result.lines.count, 1
				
		assert_equal tokens[0], "bii:tir19-001-Id"
		assert_equal tokens[1], "http://spec.cenbii.eu/BII2#tir19-Class"
		assert_equal tokens[2], "/ROOT/ELEMENT_CONCEPT/ELEMENT_PROPERTY[@attribute=1]"
	end
	
	def assert_id_content(result)
		tokens = result.split(/[;\n]/)
		
		assert_equal result.lines.count, 1
		
		assert_equal tokens[0], "bii:tir19-001-Id"
		assert_equal tokens[1], "http://spec.cenbii.eu/BII2#tir19-Class"
		assert_equal tokens[2], "/ROOT/ELEMENT_CONCEPT/ELEMENT_PROPERTY"
		assert_equal tokens[3], "\"value\""
	end
	
	def assert_id_only_attribute(result)
		tokens = result.split(/[;\n]/)
		
		assert_equal result.lines.count, 1
		
		assert_equal tokens[0], "bii:tir19-001-Id"
		assert_equal tokens[1], "http://spec.cenbii.eu/BII2#tir19-Class"
		assert_equal tokens[2], "/ROOT/ELEMENT_CONCEPT/@ELEMENT_PROPERTY"
	end
	
	def assert_id_comment(result)
		tokens = result.split(/[;\n]/)
		
		assert_equal result.lines.count, 1
		
		assert_equal tokens[0], "bii:tir19-001-Id"
		assert_equal tokens[1], "http://spec.cenbii.eu/BII2#tir19-Class"
		assert_equal tokens[2], "/ROOT/ELEMENT_CONCEPT/ELEMENT_PROPERTY"
		assert_equal tokens[3], ""
		assert_equal tokens[4], "\"A comment\""
	end
	
	def assert_id_name(result)
		tokens = result.split(/[;\n]/)
		
		assert_equal result.lines.count, 2
		
		assert_equal tokens[0], "bii:tir19-001-Id"
		assert_equal tokens[1], "http://spec.cenbii.eu/BII2#tir19-Class"
		assert_equal tokens[2], "/ROOT/ELEMENT_CONCEPT/ELEMENT_PROPERTY_1"
		
		assert_equal tokens[5], "bii:tir19-002-Name"
		assert_equal tokens[6], "http://spec.cenbii.eu/BII2#tir19-Class"
		assert_equal tokens[7], "/ROOT/ELEMENT_CONCEPT/ELEMENT_PROPERTY_2"
	end
	
	def assert_id_name_content(result)
		tokens = result.split(/[;\n]/)
		
		assert_equal result.lines.count, 2
		
		assert_equal tokens[0], "bii:tir19-001-Id"
		assert_equal tokens[1], "http://spec.cenbii.eu/BII2#tir19-Class"
		assert_equal tokens[2], "/ROOT/ELEMENT_CONCEPT/ELEMENT_PROPERTY_1"
		assert_equal tokens[3], "\"value\""
		assert_equal tokens[4], ""
		
		assert_equal tokens[5], "bii:tir19-002-Name"
		assert_equal tokens[6], "http://spec.cenbii.eu/BII2#tir19-Class"
		assert_equal tokens[7], "/ROOT/ELEMENT_CONCEPT/ELEMENT_PROPERTY_1/ELEMENT_PROPERTY_2"
	end
	
	def assert_id_two(result)
		tokens = result.split(/[;\n]/)
		
		assert_equal result.lines.count, 2
		
		assert_equal tokens[0], "bii:tir19-001-Id"
		assert_equal tokens[1], "http://spec.cenbii.eu/BII2#tir19-Class"
		assert_equal tokens[2], "/ROOT/ELEMENT_CONCEPT_1/ELEMENT_PROPERTY"
		
		assert_equal tokens[5], "bii:tir19-003-IdA"
		assert_equal tokens[6], "http://spec.cenbii.eu/BII2#tir19-ClassA"
		assert_equal tokens[7], "/ROOT/ELEMENT_CONCEPT_2/ELEMENT_PROPERTY"
	end
	
	def assert_id_two_same(result)
		tokens = result.split(/[;\n]/)
		
		assert_equal result.lines.count, 2
		
		assert_equal tokens[0], "bii:tir19-001-Id"
		assert_equal tokens[1], "http://spec.cenbii.eu/BII2#tir19-Class"
		assert_equal tokens[2], "/ROOT/ELEMENT_CONCEPT/ELEMENT_PROPERTY"
		
		assert_equal tokens[5], "bii:tir19-003-IdA"
		assert_equal tokens[6], "http://spec.cenbii.eu/BII2#tir19-ClassA"
		assert_equal tokens[7], "/ROOT/ELEMENT_CONCEPT/ELEMENT_PROPERTY"
	end
	
	def assert_id_super_sub(result)
		tokens = result.split(/[;\n]/)
		
		assert_equal result.lines.count, 2
		
		assert_equal tokens[0], "bii:tir19-001-Id"
		assert_equal tokens[1], "http://spec.cenbii.eu/BII2#tir19-Class"
		assert_equal tokens[2], "/ROOT/ELEMENT_CONCEPT/ELEMENT_PROPERTY"
		
		assert_equal tokens[5], "bii:tir19-005-IdC"
		assert_equal tokens[6], "http://spec.cenbii.eu/BII2#tir19-ClassC"
		assert_equal tokens[7], "/ROOT/ELEMENT_CONCEPT/ELEMENT_PROPERTY"
	end	
	
	def assert_id_nested(result)
		tokens = result.split(/[;\n]/)

		assert_equal result.lines.count, 2
		
		assert_equal tokens[0], "bii:tir19-001-Id"
		assert_equal tokens[1], "http://spec.cenbii.eu/BII2#tir19-Class"
		assert_equal tokens[2], "/ROOT/ELEMENT_CONCEPT_1[ELEMENT_PREDICATE='a']/ELEMENT_CONCEPT_2/ELEMENT_PROPERTY"
		
		assert_equal tokens[5], "bii:tir19-004-IdB"
		assert_equal tokens[6], "http://spec.cenbii.eu/BII2#tir19-ClassB"
		assert_equal tokens[7], "/ROOT/ELEMENT_CONCEPT_1[ELEMENT_PREDICATE='b']/ELEMENT_CONCEPT_2/ELEMENT_PROPERTY"
	end
	
	def assert_id_nested2(result)
		tokens = result.split(/[;\n]/)

		assert_equal result.lines.count, 2
		
		assert_equal tokens[0], "bii:tir19-005-IdC"
		assert_equal tokens[1], "http://spec.cenbii.eu/BII2#tir19-ClassC"
		assert_equal tokens[2], "/ROOT/ELEMENT_CONCEPT_1[ELEMENT_PREDICATE='a']/ELEMENT_CONCEPT_2/ELEMENT_PROPERTY"
		
		assert_equal tokens[5], "bii:tir19-006-IdD"
		assert_equal tokens[6], "http://spec.cenbii.eu/BII2#tir19-ClassD"
		assert_equal tokens[7], "/ROOT/ELEMENT_CONCEPT_1[ELEMENT_PREDICATE='b']/ELEMENT_CONCEPT_2/ELEMENT_PROPERTY"
	end
	
	def assert_id_nested_double(result)
		tokens = result.split(/[;\n]/)

		assert_equal result.lines.count, 2
		
		assert_equal tokens[0], "bii:tir19-005-IdC"
		assert_equal tokens[1], "http://spec.cenbii.eu/BII2#tir19-ClassC"
		assert_equal tokens[2], "/ROOT/ELEMENT_CONCEPT_1[ELEMENT_PREDICATE='a']/ELEMENT_CONCEPT_2/ELEMENT_CONCEPT_3/ELEMENT_PROPERTY"
		
		assert_equal tokens[5], "bii:tir19-006-IdD"
		assert_equal tokens[6], "http://spec.cenbii.eu/BII2#tir19-ClassD"
		assert_equal tokens[7], "/ROOT/ELEMENT_CONCEPT_1[ELEMENT_PREDICATE='b']/ELEMENT_CONCEPT_2/ELEMENT_CONCEPT_3/ELEMENT_PROPERTY"
	end
	
	def assert_id_two_roots(result)
		tokens = result.split(/[;\n]/)

		assert_equal result.lines.count, 1
		
		assert_equal tokens[0], "bii:tir19-005-IdC"
		assert_equal tokens[1], "http://spec.cenbii.eu/BII2#tir19-ClassC"
		assert_equal tokens[2], "/ROOT/ELEMENT_CONCEPT_1/ELEMENT_CONCEPT_3/ELEMENT_PROPERTY"
	end
	
	def test_property_reference
		out = do_xslt("data/property_reference.xsd")
		assert_id_only(out)
	end
	
	def test_property_noreference
		out = do_xslt("data/property_noreference.xsd")
		assert_id_only(out)
	end
	
	def test_property_typeof_noreference
		out = do_xslt("data/property_typeof_noreference.xsd")
		assert_id_two_same(out)
	end
	
	def test_property_typeof_reference
		out = do_xslt("data/property_typeof_reference.xsd")
		assert_id_two_same(out)
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
	
	def test_property_type_reuse_reference
		out = do_xslt("data/property_type_reuse_reference.xsd")
		assert_id_two(out);
	end
	
	def test_property_type_reuse_noreference
		out = do_xslt("data/property_type_reuse_noreference.xsd")
		assert_id_two(out);
	end
	
	def test_property_reference_reuse_nested
		out = do_xslt("data/property_reference_reuse_nested.xsd")
		assert_id_nested(out);
	end
	
	def test_property_nested
		out = do_xslt("data/property_nested_concept.xsd")
		assert_id_nested2(out);
	end
	
	def test_property_double_nested
		out = do_xslt("data/property_reference_double_nested.xsd")
		assert_id_nested_double(out);
	end
	
	def test_reference_type
		out = do_xslt("data/property_reference_type.xsd")
		assert_id_two(out);
	end
	
	def test_property_attribute
		out = do_xslt("data/property_attribute.xsd")
		assert_id_only_attribute(out);
	end
	
	def test_property_attribute_type
		out = do_xslt("data/property_attribute_type.xsd")
		assert_id_only_attribute(out);
	end
	
	def test_property_noreference_content
		out = do_xslt("data/property_noreference_content.xsd")
		assert_id_content(out);
	end
	
	def test_property_reference_content
		out = do_xslt("data/property_reference_content.xsd")
		assert_id_content(out);
	end
	
	def test_property_reference_content_two
		out = do_xslt("data/property_reference_content_two.xsd")
		assert_id_name_content(out);
	end
	
	def test_property_noreference_content_two
		out = do_xslt("data/property_noreference_content_two.xsd")
		assert_id_name_content(out);
	end
	
	def test_property_predicate
		out = do_xslt("data/property_predicate.xsd")
		assert_id_only_predicate(out);
	end
	
	def test_property_two_roots
		out = do_xslt("data/property_two_roots.xsd")
		assert_id_two_roots(out);
	end
	
	def test_property_domain
		out = do_xslt("data/property_domain.xsd")
		assert_id_super_sub(out);
	end
	
	def test_property_comment_reference
		out = do_xslt("data/property_comment_reference.xsd")
		assert_id_comment(out);
	end
	
	def test_property_comment_noreference
		out = do_xslt("data/property_comment_noreference.xsd")
		assert_id_comment(out);
	end
end
