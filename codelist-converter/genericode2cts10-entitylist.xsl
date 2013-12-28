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
	xmlns:cts-core="http://schema.omg.org/spec/CTS2/1.0/Core">

<xsl:output method="xml" encoding="utf-8" />

<xsl:param name="canonicalUri" select="''" />
<xsl:param name="renderUri" select="''" />
<xsl:param name="accessDate" select="'1970-01-01T00:00:00'" />

<xsl:variable
	name="codelistUri"
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
	
	<!-- Name of the column with the code -->
	<xsl:variable name="key">
		<xsl:value-of
			select="../ColumnSet/Key/ColumnRef/@Ref" />
	</xsl:variable>
	
	<cts:EntityList
		complete="COMPLETE"
		numEntries="2">

		<cts-core:heading>
			<cts-core:resourceRoot>
				<xsl:value-of select="$renderUri" />
			</cts-core:resourceRoot>
			<cts-core:resourceURI>
				<xsl:value-of select="$renderUri" />
			</cts-core:resourceURI>
			<cts-core:accessDate>
				<xsl:value-of select="$accessDate" />
			</cts-core:accessDate>
		</cts-core:heading>

		<xsl:apply-templates select="Row">
			<xsl:with-param name="key" select="$key" />
		</xsl:apply-templates>
	</cts:EntityList>

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
		name="entityRenderUri"
		select="concat($codelistRenderUri, '/', $entityId)" />
	<xsl:variable
		name="codelistName"
		select="/gc:CodeList/Identification/ShortName" />
	<xsl:variable
		name="codelistVersion"
		select="/gc:CodeList/Identification/Version" />
	<xsl:variable
		name="codelistVersionUri"
		select="''" />

	<cts:entry
		href="${entityRenderUri}"
		resourceName="{$entityId}">

		<cts:entry>

			<cts:namedEntity
				about="{$entityUri}"
				entryState="ACTIVE">

				<cts:entityID>
					<cts-core:namespace>
						<xsl:text>bii</xsl:text>
					</cts-core:namespace>
					<cts-core:name>
						<xsl:value-of select="$entityId" />
					</cts-core:name>
				</cts:entityID>

				<cts:describingCodeSystemVersion>
					<cts-core:version
						uri="codesystem/{$codelistName}/version/{$codelistVersion}"
						href="codesystem/{$codelistName}/version/{$codelistVersion}">
						<xsl:value-of select="/gc:CodeList/Identification/Version" />
					</cts-core:version>
					<cts-core:codeSystem
						href="codesystem/{$codelistName}">
						<xsl:value-of select="$codelistVersionUri" />
					</cts-core:codeSystem>
				</cts:describingCodeSystemVersion>

				<cts:designation
					designationRole="PREFERRED"
					assertedInCodeSystemVersion="{$codelistVersion}">
					<cts-core:value>
						<xsl:value-of select="$entityName" />
					</cts-core:value>
				</cts:designation>

				<cts:entityType uri="http://www.w3.org/">
					<cts-core:namespace>
						<xsl:text>skos</xsl:text>
					</cts-core:namespace>
					<cts-core:name>Concept</cts-core:name>
				</cts:entityType>
				<cts:entityType uri="http://www.w3.org/ns/adms#Item">
					<cts-core:namespace>
						<xsl:text>adms</xsl:text>
					</cts-core:namespace>
					<cts-core:name>Item</cts-core:name>
				</cts:entityType>

			</cts:namedEntity>

		</cts:entry>
	</cts:entry>

</xsl:template>

<xsl:template match="*|@*">
	<!-- ignore anything else -->
</xsl:template>

</xsl:stylesheet>
