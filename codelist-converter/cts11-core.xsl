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
	xmlns:cts-core="http://www.omg.org/spec/CTS2/1.1/Core">
		
<xsl:include href="cts-core.xsl" />

<xsl:template name="generate-heading">
	<xsl:param name="resourceRoot" select="''" />
	<xsl:param name="resourceUri" select="''" />
	<xsl:param name="accessDate" select="''" />
	
	<cts-core:heading>
		<cts-core:resourceRoot>
			<xsl:value-of select="$resourceRoot" />
		</cts-core:resourceRoot>
		<cts-core:resourceURI>
			<xsl:value-of select="$resourceUri" />
		</cts-core:resourceURI>
		<cts-core:accessDate>
			<xsl:value-of select="$accessDate" />
		</cts-core:accessDate>
	</cts-core:heading>
			
</xsl:template>

</xsl:stylesheet>
