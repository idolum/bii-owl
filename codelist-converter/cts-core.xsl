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
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template name="codesystem-uri">
	<xsl:param name="codeSystemId" select="''" />
	<xsl:text>codesystem/</xsl:text>
	<xsl:value-of select="$codeSystemId" />
</xsl:template>

<xsl:template name="codesystem-versions-uri">
	<xsl:param name="codeSystemId" select="''" />
	<xsl:param name="codeSystemVersion" select="''" />
	<xsl:call-template name="codesystem-uri">
		<xsl:with-param name="codeSystemId" select="$codeSystemId" />
	</xsl:call-template>
	<xsl:text>/versions</xsl:text>
</xsl:template>

<xsl:template name="codesystem-version-uri">
	<xsl:param name="codeSystemId" select="''" />
	<xsl:param name="codeSystemVersion" select="''" />
	<xsl:call-template name="codesystem-uri">
		<xsl:with-param name="codeSystemId" select="$codeSystemId" />
	</xsl:call-template>
	<xsl:text>/version/</xsl:text>
	<xsl:value-of select="$codeSystemVersion" />
</xsl:template>

<xsl:template name="codesystem-entities-uri">
	<xsl:param name="codeSystemId" select="''" />
	<xsl:param name="codeSystemVersion" select="''" />
	<xsl:call-template name="codesystem-version-uri">
		<xsl:with-param name="codeSystemId" select="$codeSystemId" />
		<xsl:with-param name="codeSystemVersion" select="$codeSystemVersion" />
	</xsl:call-template>
	<xsl:text>/entities</xsl:text>
</xsl:template>

<xsl:template name="codesystem-version-entity-uri">
	<xsl:param name="codeSystemId" select="''" />
	<xsl:param name="codeSystemVersion" select="''" />
	<xsl:param name="entityId" select="''" />
	<xsl:call-template name="codesystem-version-uri">
		<xsl:with-param name="codeSystemId" select="$codeSystemId" />
		<xsl:with-param name="codeSystemVersion" select="$codeSystemVersion" />
	</xsl:call-template>
	<xsl:text>/entity/</xsl:text>
	<xsl:value-of select="$entityId" />
</xsl:template>

<xsl:template name="calculate-version">
	<xsl:param name="version" select="''" />
	<xsl:variable name="minor" select="substring-after($version, '.')" />
	<xsl:variable name="major" select="substring-before($version, '.')" />
	<xsl:value-of select="(number($major) * 100) + number($minor)" />
</xsl:template>

</xsl:stylesheet>
