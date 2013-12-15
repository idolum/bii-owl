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
	encoding="utf-8"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:gc="http://docs.oasis-open.org/codelist/ns/genericode/1.0/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:rad="http://www.w3.org/ns/rad#"
	xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:adms="http://www.w3.org/ns/adms#">

<xsl:output method="xml" encoding="utf-8" />

<xsl:param name="canonicalUri" select="''" />

<xsl:variable
	name="codelistUri"
	select="
		concat(
			$canonicalUri,
			/gc:CodeList/Identification/CanonicalVersionUri)" />

<xsl:template match="/">
	<rdf:RDF>
		<xsl:apply-templates select="gc:CodeList" />
	</rdf:RDF>
</xsl:template>

<xsl:template match="gc:CodeList">
	<xsl:apply-templates select="Identification" />
	<xsl:apply-templates select="SimpleCodeList" />
</xsl:template>

<xsl:template match="Identification">
	
	<rdf:Description about="{$codelistUri}">
		<rdf:type rdf:resource="http://www.w3.org/ns/adms#SemanticAsset" />
		
		<adms:identifier>
			<xsl:value-of select="$codelistUri" />
		</adms:identifier>
		
		<rdfs:label>
			<xsl:value-of select="ShortName" />
		</rdfs:label>
		
		<rad:version>
			<xsl:value-of select="Version" />
		</rad:version>
		
		<dcterms:description>
			<xsl:value-of select="CanonicalUri" />
			<xsl:text> Codelist </xsl:text>
			<xsl:value-of select="ShortName" />
			<xsl:text> </xsl:text>
			<xsl:value-of select="Version" />
		</dcterms:description>
		
	</rdf:Description>
	
</xsl:template>

<xsl:template match="SimpleCodeList">
	
	<!-- Name of the column with the code -->
	<xsl:variable name="key">
		<xsl:value-of
			select="../ColumnSet/Key/ColumnRef/@Ref" />
	</xsl:variable>
	
	<xsl:apply-templates select="Row">
		<xsl:with-param name="key" select="$key" />
	</xsl:apply-templates>
	
</xsl:template>

<xsl:template match="Row">
	<xsl:param name="key" />
	
	<xsl:variable
		name="itemId"
		select="Value[@ColumnRef=$key]/SimpleValue" />
	<xsl:variable
		name="itemName"
		select="Value[@ColumnRef!=$key]/SimpleValue" />
	<xsl:variable
		name="itemUri"
		select="concat($codelistUri, '/', $itemId)" />

	<rdf:Description about="{$itemUri}">
		
		<rdf:type rdf:resource="http://www.w3.org/ns/adms#Item" />
		
		<rdfs:label>
			<xsl:value-of select="$itemId" />
		</rdfs:label>
		
		<dcterms:description>
			<xsl:value-of select="$itemName" />
		</dcterms:description>
		
	</rdf:Description>
	
	<rdf:Description about="{$codelistUri}">
		<adms:includedItem rdf:resource="{$itemUri}" />
	</rdf:Description>
	
</xsl:template>

<xsl:template match="*|@*">
	<!-- empty -->
</xsl:template>

</xsl:stylesheet>
