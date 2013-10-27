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

require 'rubygems'
require 'rest-client'
require 'ostruct'
require 'rdf'
require 'rdf/ntriples'
require 'rdf/raptor'
require 'rdf/json'
require 'digest/md5'

def getText(url)
  text = ""
  md5 = "cache/" + Digest::MD5.hexdigest(url)
  if File.exist? md5
    puts "Read cached " + url + "\n"
    f = File.open(md5, "r")
    f.each_line do |line|
      text += line
    end
  else
    puts "Read " + url + "\n"
    sleep(rand(5))
    response = RestClient.get url
    text = response.to_str
    File.open(md5, "w") do |f|
      f.puts text
    end
  end
  return text
end

def getValue(text, re, default)
  value = default
  text.scan(re) do |m|
    value = m[0]
  end
  return value
end

def getId(text, default)
  re = /<TD WIDTH="74%" COLSPAN="7" CLASS="f4">([^<]*)<\/TD>/
  return getValue(text, re, default)
end

def getName(text, default)
  re = /<TD WIDTH="52%" COLSPAN="4" CLASS="f5">([^<]*)<\/TD>/
  return getValue(text, re, default)
end

def getUsage(text, default)
  re = /Usage<\/TD>\s*<TD WIDTH="74%" COLSPAN="7" CLASS="f4">([^<]*)<\/TD>/
  return getValue(text, re, default)
end

def getMinCardinality(text, default)
  re = /<TD WIDTH="3%" CLASS="f4">([^<]*)<\/TD>/
  return getValue(text, re, default)
end

def getMaxCardinality(text, default)
  re = /<TD WIDTH="70%" COLSPAN="5" CLASS="f4">([^<]*)<\/TD>/
  return getValue(text, re, default)
end

def getChildren(text)
  children = Array.new
  re = /<AREA SHAPE="rect" COORDS="[^"]*" HREF="([^"]*)" target="_self">/
  text.scan(re) do |m|
    children.push(m[0])
  end
  return children
end

def writeRestriction(graph, domain, predicate, property, value)
  restriction = RDF::Node.new
  graph << [restriction, RDF.type, RDF::OWL.Restriction]
  graph << [restriction, RDF::OWL.onProperty, property]
  graph << [restriction, predicate, value]
  graph << [domain, RDF::RDFS.subClassOf, restriction]
end

def writeRangeRestriction(graph, predicate, class_, property, value)
  restriction = RDF::Node.new
  graph << [restriction, RDF.type, RDF::OWL.Restriction]
  graph << [restriction, RDF::OWL.onProperty, property]
  graph << [restriction, RDF::OWL.onClass, class_]
  graph << [restriction, predicate, value]
  graph << [property, RDF::RDFS.range, restriction]
end

def isPropertyDefined(graph, uri)
  solutions = RDF::Query.execute(graph, {
    :property => {
      RDF.type => RDF::OWL.DatatypeProperty
    }
  })

  sol = solutions.filter(:property => RDF::URI(uri))

  return sol.count != 0
end

def isClassDefined(graph, uri)
  solutions = RDF::Query.execute(graph, {
    :class => {
      RDF.type => RDF::OWL.Class
    }
  })

  sol = solutions.filter(:class => RDF::URI(uri))

  return sol.count != 0
end

def writeDataProperty(ontologyUrl, graph, id, domain, text)
  
  name = getName(text, "")
  usage = getUsage(text, "")
  min = getMinCardinality(text, "0")
  max = getMaxCardinality(text, "0")
  nid = getId(text, "") + "-" + name.gsub(/ /, "_")

  subject = RDF::URI.new(ontologyUrl + nid)

  print "  Property " + id + ", " + name + " (" + min + ".." + max + ")\n"

  type = nil
  case text
    when /BiiDT::Date/
      type = RDF::XSD.date
    when /BiiDT::Identifier/
      type = RDF::XSD.anyURI
    else
      type = RDF::XSD.string
  end   

  if not isPropertyDefined(graph, subject.to_s)
    graph << [subject, RDF.type, RDF::OWL.DatatypeProperty]
    graph << [subject, RDF.type, RDF::OWL.FunctionalProperty]
    graph << [subject, RDF::RDFS.label, name]
    graph << [subject, RDF::RDFS.comment, usage]
    graph << [subject, RDF::RDFS.range, type]
  end

  graph << [subject, RDF::RDFS.domain, domain]

  writeRestriction(graph, domain, RDF::OWL.minCardinality, subject, min)

  if max != "unbounded"
    writeRestriction(graph, domain, RDF::OWL.maxCardinality, subject, max)
  end
end

def writeClass(ontologyUrl, graph, id, domain, text)
  name = getName(text, "")
  usage = getUsage(text, "")
  min = getMinCardinality(text, "0")
  max = getMaxCardinality(text, "0")
  id = "tir19-" + name.gsub(/ /, "_")

  print "  Class " + id + ", " + name + "\n"

  subject = RDF::URI.new(ontologyUrl + id)

  if not isClassDefined(graph, subject.to_s)
    graph << [subject, RDF.type, RDF::OWL.Class]
    graph << [subject, RDF::RDFS.label, name]
    graph << [subject, RDF::RDFS.comment, usage]
  end

  property = RDF::URI.new(ontologyUrl + domain + "_" + id)
  propertyName = domain + " consists of " + id
  graph << [property, RDF.type, RDF::OWL.ObjectProperty]
  graph << [property, RDF::RDFS.domain, domain]

  writeRangeRestriction( \
    graph, RDF::OWL.minCardinality, subject, property, min)

  if max != "unbounded"
    writeRangeRestriction( \
      graph, RDF::OWL.maxCardinality, subject, property, max)
  end

  return subject
end

def retrieveOntology(ontologyUrl, graph)
  hasWorkToDo = true
  url = "g_5.htm"
  nextRe = /<A HREF="([^"]*)"><IMG ALT="Next\/Continue" SRC="b_next.gif" WIDTH="19" HEIGHT="19" BORDER="0"><\/A>/
  i = 0

  baseUrl = "http://spec.cenbii.eu/BII2/fxhtml/Trdm019-Catalogue/"

  stackChildren = Array.new
  stackClass = Array.new
  domain = RDF::URI.new(ontologyUrl + "tir19-Catalogue")
  graph << [domain, RDF.type, RDF::OWL.Class]
  graph << [domain, RDF::RDFS.label, "Catalogue"]

  while hasWorkToDo
    hasWorkToDo = false
    text = getText(baseUrl + url)

    if url != "g_5.htm"
      if text =~ /BiiDT::/
        writeDataProperty(ontologyUrl, graph, url, domain, text)
        i += 1
      else
        i += 1
        children = getChildren(text)
        domain = writeClass(ontologyUrl, graph, url, domain, text)
        
        while stackChildren.last.index(url) == nil
          stackChildren.pop
          stackClass.pop
        end

        stackClass.push(domain)
        stackChildren.push(children)
      end
    else
      children = getChildren(text)
      stackChildren.push(children)
      stackClass.push(domain)
    end

    text.scan(nextRe) { |m|
      url = m[0]
      hasWorkToDo = true
    }
  end
end

ontologyUrl = "http://spec.cenbii.eu/BII2#"

graph = RDF::Graph.new

ontology = RDF::URI.new(ontologyUrl)
version = RDF::URI.new(ontologyUrl + "/0")

graph << [ontology, RDF.type, RDF::OWL.Ontology]
graph << [ontology, RDF::OWL.versionIRI, version]

retrieveOntology(ontologyUrl, graph)

outputRdf = RDF::Writer.open("BiiTrdm019-Catalogue.rdf") do |writer|
  graph.each_statement do |statement|
    writer << statement
  end
end

