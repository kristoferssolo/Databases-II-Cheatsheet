#set page(margin: (
  top: 1cm,
  bottom: 1cm,
  right: 1cm,
  left: 1cm,
))

#set text(7pt)
#show heading: it => {
  if it.level == 1 {
    // pagebreak(weak: true)
    text(10pt, upper(it))
  } else if it.level == 2 {
    text(9pt, smallcaps(it)) 
  } else {
    text(8pt, smallcaps(it)) 
  }
}


= Indices

== Bitmap

== B+ tree

== Hash-index

= Algorithms 

== Costs

=== Nested-loop join

=== Block-nested join

=== Merge join

=== Hash-join

== Overview

= Relational-algebra

== Equivalence rules

== Operations

= Concurrency 

== Conflict-serializability

=== Conflict (types)

=== Serializability graph

== Standard consistency levels

== Protocols

=== Lock-based

=== Timestamp

=== Validation

=== Version isolation

= Logs 

== WAL principle

== Recovery algorithm

== Log type examples

== Recovery example
