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
	xmlns:sb="http://www.bmecat.org/syntaxbinding/2013">

<xsl:output method="text"/>
<xsl:param name="root">BMECAT</xsl:param>

<xsl:template match="/">
	<xsl:apply-templates select="//xsd:element[@name=$root]" />
</xsl:template>

<xsl:template match="xsd:element[@name='ARTICLE']">
</xsl:template>

<xsl:template match="xsd:element[@name='T_UPDATE_PRICES']">
</xsl:template>

<xsl:template match="xsd:element[string(@name)='T_UPDATE_PRODUCTS']">
</xsl:template>

<xsl:template name="GetFirstToken">
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

<xsl:template name="WritePath">
	<!--
		Writes the syntax binding XPath for the properties specified
		in $property and $remainingProperties.
	-->
	
	<xsl:param name="path" />
	<xsl:param name="property" />
	<xsl:param name="remainingProperties" />
	
	<!-- Write property binding -->
	<xsl:if test="$property!=''">
		<xsl:value-of select="$property" />
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

	<!-- Write remaining property bindings -->
	<xsl:if test="$remainingProperties!=''">
		<xsl:variable name="nextProperty">
			<xsl:call-template name="GetFirstToken">
				<xsl:with-param
					name="string"
					select="$remainingProperties" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:call-template name="WritePath">
			<xsl:with-param name="path" select="$path" />
			<xsl:with-param
				name="property"
				select="$nextProperty" />
			<xsl:with-param
				name="remainingProperties"
				select="substring-after($remainingProperties, ' ')" />
		</xsl:call-template>
	</xsl:if>
	
</xsl:template>

<xsl:template name="IterateTypeofs">
	<xsl:param name="name" />
	<xsl:param name="typeof" />
	<xsl:param name="remainingTypeofs" />
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
		<xsl:apply-templates select="//xsd:element[@name=$name]">
			<xsl:with-param name="path" select="$path" />
			<xsl:with-param name="predicate" select="$predicate" />
		</xsl:apply-templates>
	</xsl:if>

	<!-- Bind remaining concepts -->
	<xsl:if test="$remainingTypeofs!=''">
		<xsl:variable name="nextTypeof">
			<xsl:call-template name="GetFirstToken">
				<xsl:with-param
					name="string"
					select="$remainingTypeofs" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:call-template name="IterateTypeofs">
			<xsl:with-param name="name" select="$name" />
			<xsl:with-param name="typeof" select="$nextTypeof" />
			<xsl:with-param
				name="remainingTypeofs"
				select="substring-after($remainingTypeofs, ' ')" />
			<xsl:with-param name="path" select="$path" />
		</xsl:call-template>
	</xsl:if>
					
</xsl:template>

<xsl:template match="xsd:element[count(@*[local-name()='property'])=1]">
	<xsl:param name="path" />
	<xsl:variable
		name="properties"
		select="string(@*[local-name()='property'])" />
	<xsl:message>
		Hallo
		<xsl:value-of select="$properties" />
	</xsl:message>

	<xsl:call-template name="WritePath">
		<xsl:with-param name="path" select="$path" />
		<xsl:with-param
			name="property"
			select="substring-before($properties, ' ')" />
		<xsl:with-param
			name="remainingProperties"
			select="substring-after($properties, ' ')" />
	</xsl:call-template>
	
</xsl:template>

<xsl:template match="xsd:element[count(@name)=1 and count(@ref)=0]">
	<xsl:param name="path" />
	<xsl:param name="predicate" select="''" />
	<xsl:variable name="type" select="@type" />
	<xsl:variable name="name" select="@name" />
	<xsl:choose>
		<xsl:when test="xsd:complexType">
			<xsl:apply-templates select="xsd:complexType">
				<xsl:with-param
					name="path"
					select="concat($path, '/', $name, $predicate)" />
			</xsl:apply-templates>
		</xsl:when>
		<xsl:otherwise>
			<xsl:if test="starts-with($type, 'udx')">
				<xsl:apply-templates select="//xsd:complexType[@name=$type]">
					<xsl:with-param
						name="path"
						select="concat($path, '/', $name, $predicate)" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="xsd:element[count(@name)=0 and count(@ref)=1]">
	<xsl:param name="path" />
	<xsl:variable name="ref" select="@ref" />
	<xsl:choose>
		<xsl:when test="count(@*[local-name()='property'])=1">
			<xsl:variable name="property">
				<xsl:call-template name="GetFirstToken">
					<xsl:with-param
						name="string"
						select="@sb:property" />
				</xsl:call-template>
			</xsl:variable>
			<xsl:call-template name="WritePath">
				<xsl:with-param name="path" select="$path" />
				<xsl:with-param
					name="property"
					select="$property" />
				<xsl:with-param
					name="remainingProperties"
					select="substring-after(@sb:property, ' ')" />
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:choose>
				<xsl:when test="@sb:typeof">
					<xsl:variable name="typeof">
						<xsl:call-template name="GetFirstToken">
							<xsl:with-param
								name="string"
								select="@sb:typeof" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:call-template name="IterateTypeofs">
						<xsl:with-param name="name" select="$ref" />
						<xsl:with-param name="typeof" select="$typeof" />
						<xsl:with-param
							name="remainingTypeofs"
							select="substring-after(@sb:typeof, ' ')" />
						<xsl:with-param name="path" select="$path" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="//xsd:element[@name=$ref]">
						<xsl:with-param
							name="path"
							select="$path" />
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose> 
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="xsd:complexType|xsd:sequence|xsd:choice">
	<xsl:param name="path" />
	<xsl:apply-templates
		select="
			xsd:complexType
				| xsd:sequence
				| xsd:choice
				| xsd:element">
		<xsl:with-param name="path" select="$path" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="*|@*">
</xsl:template>

</xsl:stylesheet>
