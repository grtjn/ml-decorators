# ml-decorators

Custom MarkLogic result decorator functions

## Install

Installation depends on the [MarkLogic Package Manager](https://github.com/joemfb/mlpm):

```
$ mlpm install ml-decorators --save
$ mlpm deploy
```

## facet-values-decorator

A decorator function that adds for each result the values of facets defined in the search options. Includes values from all facets by default (including custom facets!), or you can specify a list like with the currently deprecated `extract-metadata`.

Disable any existing `extract-metadata` (it would just generate duplicates), and add something like the following:

```xml
  <result-decorator apply="decorate" ns="http://marklogic.com/facet-values-decorator" at="/ext/mlpm_modules/ml-decorators/facet-values-decorator.xqy">
    <annotation>
      <extract-metadata>
        <constraint-value ref="Content-Type"/> <!-- xs:string -->
        <constraint-value ref="Document-Type"/> <!-- custom with start-facet and finish-facet -->
        <constraint-value ref="Size"/> <!-- xs:int, buckets -->
        <constraint-value ref="Modified-Date"/> <!-- xs:dateTime, computed-buckets -->
      </extract-metadata>
    </annotation>
  </result-decorator>
```

Note: including custom facets slows down a little (x 10), otherwise performance pretty comparable with the original extract-metadata.
