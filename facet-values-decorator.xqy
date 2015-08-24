xquery version "1.0-ml";

module namespace deco = "http://marklogic.com/facet-values-decorator";

import module namespace sut = "http://marklogic.com/rest-api/lib/search-util" at "/MarkLogic/rest-api/lib/search-util.xqy";
import module namespace impl = "http://marklogic.com/appservices/search-impl" at "/MarkLogic/appservices/search/search-impl.xqy";

declare namespace search = "http://marklogic.com/appservices/search";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare option xdmp:mapping "false";

declare variable $options-name := xdmp:get-request-field("options", "default");
declare variable $options := sut:options(map:entry("options", $options-name));
declare variable $default-scope := ($options/search:fragment-scope, "all")[1];
declare variable $facets := deco:_get-facets();
declare variable $facet-names :=
  for $facet in $facets
  return
    replace($facet/@name, '[^a-zA-Z0-9\-_.]', '_')
  ;
declare variable $references :=
  for $facet in $facets
  return
    if ($facet/search:custom) then
      <skip/>
    else
      impl:construct-reference(impl:get-refspecs($facet))
  ;

declare function deco:decorate($uri as xs:string) as node()*
{
  <search:metadata xmlns:search="http://marklogic.com/appservices/search">{
    
    let $query := cts:document-query($uri)
    let $serialized-query := document{$query}/*
    let $forests := xdmp:document-forest($uri)
    
    for $facet at $pos in $facets
    let $name := $facet-names[$pos]
    return
    if ($facet/search:custom) then
      let $start :=
        impl:start-facet(
          $facet,
          (),
          $serialized-query,
          1, 
          $forests
        )
      let $finish :=
        impl:finish-facet(
          $facet,
          (),
          $start,
          $serialized-query,
          1,
          $forests
        )
      for $value in $finish/*
      return
        <search:constraint-meta name="{ $name }">{ data($value) }</search:constraint-meta>
    else
      let $reference := $references[$pos]
      let $scope as xs:string := ($facet/*/search:fragment-scope, $default-scope)[1]
      let $values :=
        cts:values(
          $reference,
          (),
          ($scope),
          $query,
          1,
          $forests
        )
      for $value in $values
      return
        <search:constraint-meta name="{ $name }">{ $value }</search:constraint-meta>
    
  }</search:metadata>
};

declare private function deco:_get-facets()
  as element(search:constraint)*
{
  let $extract-constraints := $options/search:result-decorator/search:annotation/search:extract-metadata/search:constraint-value/@ref
  return
    $options/search:constraint[empty($extract-constraints) or @name = $extract-constraints][*[@facet or exists(search:heatmap) or (exists(search:start-facet) and exists(search:finish-facet))]]
};