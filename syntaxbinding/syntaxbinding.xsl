<?xml version="1.0" encoding="utf-8"?>
<!--
The MIT License (MIT)

Copyright (c) 2013 Veit Jahns

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
-->
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	xmlns:sb="http://www.bmecat.org/syntaxbinding/2013"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#">

<xsl:output method="text"/>
<xsl:param name="root">BMECAT</xsl:param>
<xsl:param name="ontology-file">BiiTrdm019-Catalogue.rdf</xsl:param>

<xsl:variable name="ontology" select="document($ontology-file)" />

<xsl:template match="/">
	<xsl:apply-templates select="//xsd:element[@name=$root]" />
</xsl:template>

<xsl:template name="get-first-token">
	<!--
		Returns the first token from $string or while $string is a
		whitespace separated tokenlist.
	-->	
	
	<xsl:param name="string" />
	
	<xsl:choose>
		<xsl:when
			test="substring-before($string, ' ')=''">
			<xsl:value-of select="$string" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="substring-before($string, ' ')" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="resolve-curi">
	<!--
		Resolves a CURI ($curi) to a complete URI.
	-->
	
	<xsl:param name="curi" select="''" />
	
	<xsl:variable
		name="prefix"
		select="substring-before($curi, ':')" />
	
	<xsl:variable
		name="namespace-uri"
		select="/xsd:schema/xsd:annotation/xsd:appinfo/sb:namespace[sb:prefix=$prefix]/sb:uri" />

	<xsl:value-of
		select="
			concat(
				$namespace-uri,
				substring-after($curi, ':'))" />
</xsl:template>

<xsl:template name="write-path">
	<!--
		Writes the syntax binding XPath for the properties specified
		in $property and $remaining-properties.
	-->

	<xsl:param name="path" />
	<xsl:param name="property" />
	<xsl:param name="remaining-properties" />
	<xsl:param name="current-concept" select="''" />
	
	<!-- Write property binding -->
	<xsl:if test="$property!=''">
					
		<xsl:variable name="current-concept-uri">
			<xsl:call-template name="resolve-curi">
				<xsl:with-param name="curi" select="$current-concept" />
			</xsl:call-template>
		</xsl:variable>
		
					
		<xsl:variable name="property-uri">
			<xsl:call-template name="resolve-curi">
				<xsl:with-param name="curi" select="$property" />
			</xsl:call-template>
		</xsl:variable>
			
		<xsl:variable
			name="property-concept"
			select="$ontology/rdf:RDF/rdf:Description[@rdf:about=$property-uri]/rdfs:domain/@rdf:resource" />
			
		<xsl:if test="$property-concept=$current-concept-uri">
			<xsl:value-of select="$property" />
			<xsl:text>;</xsl:text>
			<xsl:value-of select="$current-concept-uri" />
			<xsl:text>;</xsl:text>
			<xsl:value-of select="$path" />
			<xsl:text>/</xsl:text>
			<xsl:choose>
				<xsl:when test="@ref">
					<xsl:value-of select="@ref" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@name" />
				</xsl:otherwise>
			</xsl:choose>	
			<xsl:text>
</xsl:text>
		</xsl:if>
	</xsl:if>

	<!-- Write remaining property bindings -->
	<xsl:if test="$remaining-properties!=''">
		
		<xsl:variable name="next-property">
			<xsl:call-template name="get-first-token">
				<xsl:with-param
					name="string"
					select="$remaining-properties" />
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:call-template name="write-path">
			<xsl:with-param name="path" select="$path" />
			<xsl:with-param
				name="property"
				select="$next-property" />
			<xsl:with-param
				name="remaining-properties"
				select="substring-after($remaining-properties, ' ')" />
			<xsl:with-param
				name="current-concept"
				select="$current-concept" />
		</xsl:call-template>
	</xsl:if>
	
</xsl:template>

<xsl:template name="iterate-typeofs">
	<xsl:param name="name" />
	<xsl:param name="typeof" />
	<xsl:param name="remaining-typeofs" />
	<xsl:param name="path" />
					
	<!-- Bind the concept -->
	<xsl:if test="$typeof!=''">
		
		<xsl:variable name="predicate">
			<xsl:if test="contains($typeof, '[')">
				<xsl:text>[</xsl:text>
				<xsl:value-of
					select="
						substring-before(
							substring-after($typeof, '['),
							']')" />
				<xsl:text>]</xsl:text>
			</xsl:if>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="@ref">
				<xsl:apply-templates select="//xsd:element[@name=$name]">
					<xsl:with-param name="path" select="$path" />
					<xsl:with-param name="predicate" select="$predicate" />
					<xsl:with-param name="current-concept">
						<xsl:choose>
							<xsl:when test="contains($typeof, '[')">
							<xsl:value-of
								select=" substring-before($typeof, '[')" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$typeof" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="xsd:complexType">
					<xsl:with-param name="path" select="$path" />
					<xsl:with-param name="predicate" select="$predicate" />
					<xsl:with-param name="current-concept">
						<xsl:choose>
							<xsl:when test="contains($typeof, '[')">
							<xsl:value-of
								select=" substring-before($typeof, '[')" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$typeof" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:apply-templates>				
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:if>

	<!-- Bind remaining concepts -->
	<xsl:if test="$remaining-typeofs!=''">
		
		<xsl:variable name="nextTypeof">
			<xsl:call-template name="get-first-token">
				<xsl:with-param
					name="string"
					select="$remaining-typeofs" />
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:call-template name="iterate-typeofs">
			<xsl:with-param name="name" select="$name" />
			<xsl:with-param name="typeof" select="$nextTypeof" />
			<xsl:with-param
				name="remaining-typeofs"
				select="substring-after($remaining-typeofs, ' ')" />
			<xsl:with-param name="path" select="$path" />
		</xsl:call-template>
		
	</xsl:if>
					
</xsl:template>

<xsl:template match="xsd:element[count(@*[local-name()='property'])=1]">
	<xsl:param name="path" />
	<xsl:param name="current-concept" select="''" />
	
	<xsl:variable
		name="properties"
		select="string(@*[local-name()='property'])" />

	<xsl:call-template name="write-path">
		<xsl:with-param name="path" select="$path" />
		<xsl:with-param
			name="property"
			select="substring-before($properties, ' ')" />
		<xsl:with-param
			name="remaining-properties"
			select="substring-after($properties, ' ')" />
		<xsl:with-param
			name="current-concept"
			select="$current-concept" />
	</xsl:call-template>
	
</xsl:template>

<xsl:template match="xsd:element[count(@name)=1 and count(@ref)=0]">
	<xsl:param name="path" />
	<xsl:param name="predicate" select="''" />
	<xsl:param name="current-concept" select="''" />
	
	<xsl:variable name="type" select="@type" />
	<xsl:variable name="name" select="@name" />
			
	<xsl:if test="count(@*[local-name()='property'])=1">

		<xsl:variable name="property">
			<xsl:call-template name="get-first-token">
				<xsl:with-param
					name="string"
					select="@sb:property" />
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:call-template name="write-path">
			<xsl:with-param name="path" select="$path" />
			<xsl:with-param
				name="property"
				select="$property" />
			<xsl:with-param
				name="remaining-properties"
				select="substring-after(@sb:property, ' ')" />
			<xsl:with-param
				name="current-concept"
				select="$current-concept" />
		</xsl:call-template>
		
	</xsl:if>
	
	<xsl:choose>
		<xsl:when test="@sb:typeof">
			
			<xsl:variable name="typeof">
				<xsl:call-template name="get-first-token">
					<xsl:with-param
						name="string"
						select="@sb:typeof" />
				</xsl:call-template>
			</xsl:variable>
			
			<xsl:call-template name="iterate-typeofs">
				<xsl:with-param name="name" select="$name" />
				<xsl:with-param name="typeof" select="$typeof" />
				<xsl:with-param
					name="remaining-typeofs"
					select="substring-after(@sb:typeof, ' ')" />
				<xsl:with-param
					name="path"
					select="concat($path, '/', $name, $predicate)" />
			</xsl:call-template>
			
		</xsl:when>
		<xsl:otherwise>
			<xsl:choose>
				<xsl:when test="xsd:complexType">
					<xsl:apply-templates select="xsd:complexType">
						<xsl:with-param
							name="path"
							select="concat($path, '/', $name, $predicate)" />
						<xsl:with-param
							name="current-concept"
							select="$current-concept" />
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="starts-with($type, 'udx') or $type='typeADDRESS'">
						<xsl:apply-templates select="//xsd:complexType[@name=$type]">
							<xsl:with-param
								name="path"
								select="concat($path, '/', $name, $predicate)" />
							<xsl:with-param
								name="current-concept"
								select="$current-concept" />
						</xsl:apply-templates>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
		
</xsl:template>

<xsl:template match="xsd:element[count(@name)=0 and count(@ref)=1]">
	<xsl:param name="path" />
	<xsl:param name="current-concept" select="''" />
	
	<xsl:variable name="ref" select="@ref" />
	
	<xsl:choose>
		<xsl:when test="count(@*[local-name()='property'])=1">
			
			<xsl:variable name="property">
				<xsl:call-template name="get-first-token">
					<xsl:with-param
						name="string"
						select="@sb:property" />
				</xsl:call-template>
			</xsl:variable>
			
			<xsl:call-template name="write-path">
				<xsl:with-param name="path" select="$path" />
				<xsl:with-param
					name="property"
					select="$property" />
				<xsl:with-param
					name="remaining-properties"
					select="substring-after(@sb:property, ' ')" />
				<xsl:with-param
					name="current-concept"
					select="$current-concept" />
			</xsl:call-template>
			
		</xsl:when>
		<xsl:otherwise>
			<xsl:choose>
				<xsl:when test="@sb:typeof">
					
					<xsl:variable name="typeof">
						<xsl:call-template name="get-first-token">
							<xsl:with-param
								name="string"
								select="@sb:typeof" />
						</xsl:call-template>
					</xsl:variable>
					
					<xsl:call-template name="iterate-typeofs">
						<xsl:with-param name="name" select="$ref" />
						<xsl:with-param name="typeof" select="$typeof" />
						<xsl:with-param
							name="remaining-typeofs"
							select="substring-after(@sb:typeof, ' ')" />
						<xsl:with-param name="path" select="$path" />
					</xsl:call-template>
					
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="//xsd:element[@name=$ref]">
						<xsl:with-param
							name="path"
							select="$path" />
						<xsl:with-param
							name="current-concept"
							select="$current-concept" />
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose> 
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="xsd:complexType|xsd:sequence|xsd:choice">
	<xsl:param name="path" />
	<xsl:param name="predicate" select="''" />
	<xsl:param name="current-concept" select="''" />

	<xsl:apply-templates
		select="
			xsd:complexType
				| xsd:sequence
				| xsd:choice
				| xsd:element">
		<xsl:with-param name="path" select="$path" />
		<xsl:with-param name="predicate" select="$predicate" />
		<xsl:with-param
			name="current-concept"
			select="$current-concept" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="*|@*">
</xsl:template>

</xsl:stylesheet>
