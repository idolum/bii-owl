<?xml version="1.0" encoding="utf-8"?>
<!--
The MIT License (MIT)

Copyright (c) 2013-2014 Veit Jahns

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

<xsl:param name="canonicalUri" select="''" />
<xsl:param name="renderUri" select="''" />
<xsl:param name="accessDate" select="'1970-01-01T00:00:00'" />
<xsl:param name="entityId" select="'Code1'" />

<xsl:include href="cts10-core.xsl" />

<xsl:variable
	name="codelistUri"
	select="
		concat(
			$canonicalUri,
			/gc:CodeList/Identification/CanonicalUri)" />
<xsl:variable
	name="codelistRenderUri"
	select="concat($renderUri, '/')" />
	
<xsl:variable
	name="codeSystemVersionUri"
	select="
		concat(
			$canonicalUri,
			/gc:CodeList/Identification/CanonicalVersionUri)" />
				
<xsl:template match="/">
	<xsl:apply-templates select="gc:CodeList" />
</xsl:template>

<xsl:template match="gc:CodeList">
		
	<!--
		Variable with dummy element for adding a namespace node via
		xsl:copy-of.
		
		See also http://stackoverflow.com/questions/12179258
	 -->
	<xsl:variable name="ns">
		<xsl:element name="bii:dummy" namespace="{$codelistUri}" />
	</xsl:variable>
	<xsl:variable name="adms">
		<xsl:element
			name="adms:dummy"
			namespace="http://www.w3.org/ns/adms" />
	</xsl:variable>
	<xsl:variable name="skos">
		<xsl:element
			name="skos:dummy"
			namespace="http://www.w3.org/2004/02/skos/core" />
	</xsl:variable>
	
	<cts:EntityDescriptionMsg>
		
		<xsl:copy-of select="exslt:node-set($ns)/*/namespace::bii" />
		<xsl:copy-of select="exslt:node-set($adms)/*/namespace::adms" />
		<xsl:copy-of select="exslt:node-set($skos)/*/namespace::skos" />
		
		<xsl:call-template name="generate-heading">
			<xsl:with-param name="resourceRoot" select="$renderUri" />
			<xsl:with-param name="resourceUri">
				<xsl:call-template name="codesystem-version-entity-uri">
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
					<xsl:with-param
						name="entityId"
						select="$entityId" />
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="accessDate" select="$accessDate" />
		</xsl:call-template>
		
		<xsl:apply-templates select="SimpleCodeList" />
	</cts:EntityDescriptionMsg>
	
</xsl:template>

<xsl:template match="SimpleCodeList">
	
	<!-- Name of the column with the code -->
	<xsl:variable name="key">
		<xsl:value-of
			select="../ColumnSet/Key/ColumnRef/@Ref" />
	</xsl:variable>
	
	<cts:EntityDescription>
				
		<xsl:apply-templates select="Row[Value/SimpleValue=$entityId]">
			<xsl:with-param name="key" select="$key" />
		</xsl:apply-templates>
		
	</cts:EntityDescription>
</xsl:template>

<xsl:template match="Row">
	<xsl:param name="key" />
	
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
		
	<xsl:variable
		name="entityName"
		select="Value[@ColumnRef!=$key]/SimpleValue" />
	<xsl:variable
		name="entityUri"
		select="concat($codelistUri, '/', $entityId)" />
				
	<cts:namedEntity about="{$entityUri}" entryState="ACTIVE">
		
		<cts:entityID>
			<xsl:call-template name="generate-scoped-entity-name">
				<xsl:with-param name="namespace">
					<xsl:text>bii</xsl:text>
				</xsl:with-param>
				<xsl:with-param name="name" select="$entityId" />
			</xsl:call-template>
		</cts:entityID>
		
		<cts:describingCodeSystemVersion>
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
					<xsl:value-of select="$renderUri" />
					<xsl:call-template name="codesystem-uri">
						<xsl:with-param
							name="codeSystemId"
							select="$codelistName" />
					</xsl:call-template>
				</xsl:attribute>
				
				<xsl:value-of select="$codelistName" />
			</cts-core:codeSystem>
		</cts:describingCodeSystemVersion>
		
		<cts:designation
			designationRole="PREFERRED"
			assertedInCodeSystemVersion="{/gc:CodeList/Identification/Version}">
			<cts-core:value>
				<xsl:value-of select="$entityName" />
			</cts-core:value>
		</cts:designation>
		
		<cts:entityType
			uri="http://www.w3.org/2004/02/skos/core#Concept">
			<xsl:call-template name="generate-scoped-entity-name">
				<xsl:with-param name="namespace">
					<xsl:text>skos</xsl:text>
				</xsl:with-param>
				<xsl:with-param name="name">
					<xsl:text>Concept</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</cts:entityType>
		
		<cts:entityType uri="http://www.w3.org/ns/adms#Item">
			<xsl:call-template name="generate-scoped-entity-name">
				<xsl:with-param name="namespace">
					<xsl:text>adms</xsl:text>
				</xsl:with-param>
				<xsl:with-param name="name">
					<xsl:text>Item</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</cts:entityType>
		
	</cts:namedEntity>
</xsl:template>

<xsl:template match="*|@*">
	<!-- ignore anything else -->
</xsl:template>

</xsl:stylesheet>
