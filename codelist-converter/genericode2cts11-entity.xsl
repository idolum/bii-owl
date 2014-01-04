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
	xmlns:cts="http://www.omg.org/spec/CTS2/1.1/Entity"
	xmlns:cts-core="http://www.omg.org/spec/CTS2/1.1/Core">
	
<xsl:output method="xml" encoding="utf-8" />

<xsl:param name="canonicalUri" select="''" />
<xsl:param name="renderUri" select="''" />
<xsl:param name="accessDate" select="'1970-01-01T00:00:00'" />
<xsl:param name="entityId" select="'Code1'" />

<xsl:include href="cts11-core.xsl" />

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
	
	<cts:EntityDescriptionMsg>
		
		<xsl:call-template name="generate-heading">
			<xsl:with-param name="resourceRoot" select="$renderUri" />
			<xsl:with-param name="resourceUri">
				<xsl:call-template name="codesystem-version-entity-uri">
					<xsl:with-param
						name="codeSystemId"
						select="/gc:CodeList/Identification/ShortName" />
					<xsl:with-param
						name="codeSystemVersion"
						select="/gc:CodeList/Identification/Version" />
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
	<cts:EntityDescription>
	</cts:EntityDescription>
</xsl:template>

<xsl:template match="*|@*">
	<!-- ignore anything else -->
</xsl:template>

</xsl:stylesheet>
