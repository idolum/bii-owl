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
	xmlns:cts="http://schema.omg.org/spec/CTS2/1.0/Entity"
	xmlns:cts-core="http://schema.omg.org/spec/CTS2/1.0/Core"
	xmlns:exslt="http://exslt.org/common"
	extension-element-prefixes="exslt">

<xsl:output method="xml" encoding="utf-8" />

<xsl:include href="http://idolum.caelum.uberspace.de/xslt/cts10-core.xsl" />

<xsl:param name="canonicalUri" select="''" />
<xsl:param name="renderUri" select="''" />
<xsl:param name="accessDate" select="'1970-01-01T00:00:00Z'" />

<xsl:variable
	name="codelistUri"
	select="
		concat(
			$canonicalUri,
			/gc:CodeList/Identification/CanonicalVersionUri)" />
<xsl:variable
	name="codeSystemVersionUri"
	select="
		concat(
			$canonicalUri,
			/gc:CodeList/Identification/CanonicalVersionUri)" />
<xsl:variable
	name="codelistRenderUri"
	select="concat($renderUri, '/')" />

<xsl:template match="/">
	<xsl:apply-templates select="gc:CodeList" />
</xsl:template>

<xsl:template match="gc:CodeList">
	<xsl:apply-templates select="SimpleCodeList" />
</xsl:template>

<xsl:template match="SimpleCodeList">
	
	<xsl:variable
		name="codelistName"
		select="/gc:CodeList/Identification/ShortName" />
	<xsl:variable
		name="codelistVersion"
		select="/gc:CodeList/Identification/Version" />
		
	<!-- Name of the column with the code -->
	<xsl:variable name="key">
		<xsl:value-of
			select="../ColumnSet/Key/ColumnRef/@Ref" />
	</xsl:variable>
	
	<!--
		Variable with dummy element for adding a namespace node via
		xsl:copy-of.
		
		See also http://stackoverflow.com/questions/12179258
	 -->
	<xsl:variable name="ns">
		<xsl:element name="bii:dummy" namespace="{$codelistUri}" />
	</xsl:variable>
	
	<cts:EntityDirectory
		complete="COMPLETE"
		numEntries="2">
		
		<xsl:copy-of select="exslt:node-set($ns)/*/namespace::bii" />
		
		<xsl:call-template name="generate-heading">
			<xsl:with-param name="resourceRoot" select="$renderUri" />
			<xsl:with-param name="resourceUri">
				<xsl:call-template name="codesystem-entities-uri">
					<xsl:with-param
						name="codeSystemId"
						select="/gc:CodeList/Identification/ShortName" />
					<xsl:with-param name="codeSystemVersion">
						<xsl:call-template name="calculate-version">
							<xsl:with-param
								name="version"
								select="/gc:CodeList/Identification/Version" />
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="accessDate" select="$accessDate" />
		</xsl:call-template>
		
		<xsl:apply-templates select="Row">
			<xsl:with-param name="key" select="$key" />
		</xsl:apply-templates>
				
	</cts:EntityDirectory>

</xsl:template>

<xsl:template match="Row">
	<xsl:param name="key" />
	
	<xsl:variable
		name="entityId"
		select="Value[@ColumnRef=$key]/SimpleValue" />
	<xsl:variable
		name="entityName"
		select="Value[@ColumnRef!=$key]/SimpleValue" />
	<xsl:variable
		name="entityUri"
		select="concat($codelistUri, '/', $entityId)" />
	<xsl:variable
		name="codelistName"
		select="/gc:CodeList/Identification/ShortName" />
	<xsl:variable name="codelistVersion">
		<xsl:call-template name="calculate-version">
			<xsl:with-param
				name="version"
				select="/gc:CodeList/Identification/Version" />
		</xsl:call-template>
	</xsl:variable>
				
	<cts:entry
		about="{$entityUri}"
		resourceName="{$entityId}">

		<xsl:attribute name="href">
			<xsl:value-of select="$renderUri" />
			<xsl:call-template name="codesystem-version-entity-uri">
				<xsl:with-param
					name="codeSystemId"
					select="$codelistName" />
				<xsl:with-param
					name="codeSystemVersion"
					select="$codelistVersion" />
				<xsl:with-param
					name="entityId"
					select="$entityId" />
			</xsl:call-template>
		</xsl:attribute>
		
		<cts-core:name>
			<cts-core:namespace>
				<xsl:text>bii</xsl:text>
			</cts-core:namespace>
			<cts-core:name>
				<xsl:value-of select="$entityId" />
			</cts-core:name>
		</cts-core:name>
		
		<cts-core:knownEntityDescription>
			<cts-core:describingCodeSystemVersion>
				<cts-core:version uri="{$codeSystemVersionUri}">
					
					<xsl:attribute name="href">
						<xsl:value-of select="$renderUri" />
						<xsl:call-template name="codesystem-version-uri">
							<xsl:with-param
								name="codeSystemId"
								select="$codelistName" />
							<xsl:with-param
								name="codeSystemVersion"
								select="$codelistVersion" />
						</xsl:call-template>
					</xsl:attribute>
					
					<xsl:value-of
						select="/gc:CodeList/Identification/Version" />
				</cts-core:version>
				<cts-core:codeSystem uri="{$codelistUri}">
					
					<xsl:attribute name="href">
						<xsl:call-template name="codesystem-uri">
							<xsl:with-param
								name="codeSystemId"
								select="$codelistName" />
						</xsl:call-template>
					</xsl:attribute>
					
					<xsl:value-of select="$codelistName" />
				</cts-core:codeSystem>
			</cts-core:describingCodeSystemVersion>
			<cts-core:designation>
				<xsl:value-of select="$entityName" />
			</cts-core:designation>
		</cts-core:knownEntityDescription>
		
	</cts:entry>

</xsl:template>

<xsl:template match="*|@*">
	<!-- ignore anything else -->
</xsl:template>

</xsl:stylesheet>
