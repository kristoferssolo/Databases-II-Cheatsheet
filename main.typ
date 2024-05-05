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


== Nested-loop join

=== Overview

=== Cost

== Block-nested join

=== Overview

=== Cost

== Merge join

=== Overview

=== Cost

== Hash-join

=== Overview

=== Cost


= Relational-algebra

== Equivalence rules

- *Commutativity*: $R∪S=S∪R$; Intersection: $R∩S=S∩R$; Join: $R join S=S
  join R$; Selection : $ sigma p_1( sigma p_2(R))= sigma p_2( sigma p_1(R))$.
- *Associativity*: $(R∪S)∪T=R∪(S∪T)$; Intersection: $(R∩S)∩T=R∩(S∩T)$;
  Join: $(R join S) join T=R join (S join T)$; Theta joins are associative in
  the following manner: $(E_1  join_theta_1 E_2)  join_(theta_2 and theta_3)
  E_3 ≡E_1  join_(theta_1 or theta_3) (E_2 join_theta_2 E_3)$ 
- *Distributivity*: Distributivity of Union over Intersection:
  $R∪(S∩T)=(R∪S)∩(R∪T)$; Intersection over Union: $R∩(S∪T)=(R∩S)∪(R∩T)$ Join over
  Union: $R join (S∪T)=(R join S)∪(R join T)$; Selection Over Union:
  $ sigma p(R∪S)= sigma p(R)∪ sigma p(S)$; Projection Over Union: $pi c(R∪S)=pi c(R)∪pi c(S)$;
- Selection and Join Commutativity:  $ sigma p(R join S)= sigma p(R) join S$ if
  p involves only attributes of R
- Pushing Selections Through Joins:  $ sigma p(R join S)=( sigma p(R)) join S$
  when p only involves attributes of R
- Pushing Projections Through Joins: $pi c(R join S)=pi c(pi_(c sect #[attr])
  (R) join pi_(c sect #[attr]) (S))$ 

== Operations

- Projection ($pi$). Syntax: $pi_{#[attributes]}(R)$. Purpose: Reduces the
  relation to only contain specified attributes. Example: $pi_{#[Name,
  Age}]}(#[Employees])$

- Selection ($sigma$). Syntax: $sigma_{#[condition]}(R)$. Purpose: Filters rows
  that meet the condition. Example: $sigma_{#[Age] > 30}(#[Employees])$

- Union ($union$). Syntax: $R union S$. Purpose: Combines tuples from both
  relations, removing duplicates. Requirement: Relations must be
  union-compatible.

- Intersection ($sect$). Syntax: $R sect S$. Purpose: Retrieves tuples common
  to both relations. Requirement: Relations must be union-compatible.

- Difference ($-$). Syntax: $R - S$. Purpose: Retrieves tuples in R that are
  not in S. Requirement: Relations must be union-compatible.

- Cartesian Product ($times$). Syntax: $R times S$. Purpose: Combines tuples
  from R with every tuple from S.

- Natural Join ($join$). Syntax: $R join S$. Purpose: Combines tuples from R
  and S based on common attribute values.

- Theta Join ($join_theta$). Syntax: $R join_theta S$. Purpose: Combines tuples
  from R and S where the theta condition holds.

- Full Outer Join: $R join.l.r S$. Left Outer Join: $R join.l S$.
  Right Outer Join: $R join.r S$. Purpose: Extends join to include non-matching
  tuples from one or both relations, filling with nulls.


= Concurrency 


=== Conflict

We say that I and J conflict if they are operations by *different transactions* on the
*same data item*, and at least one of these instructions is a *write* operation.
For example: I = read(Q), J = read(Q) -- Not a conflict; I = read(Q), J =
write(Q) -- Conflict; I = write(Q), J = read(Q) -- Conflict; I = write(Q), J =
write(Q) -- Conflict. 

// + I = read(Q), J = read(Q). The order of I and J *does not matter*, since the same
//   value of Q is read by $T_i$ and $T _j$, regardless of the order.
//
// + I = read(Q), J = write(Q). If I comes before J, then Ti does not read the value
//   of Q that is written by Tj in instruction J. If J comes before I, then Ti reads the
//   value of Q that is written by Tj. Thus, the order of I and J *matters*.
//
// + I = write(Q), J = read(Q). The order of I and J *matters* for reasons similar to
//   those of the previous case.
//
// + I = write(Q), J = write(Q). Since both instructions are write operations, the
//   order of these instructions does not affect either Ti or Tj. However, the value
//   obtained by the next read(Q) instruction of S is affected, since the result of only
//   the latter of the two write instructions is preserved in the database. If there is no
//   other write(Q) instruction after I and J in S, then the order of I and J *directly
//   affects the final value* of Q in the database state that results from schedule S.

== Conflict-serializability

If a schedule $S$ can be transformed into a schedule $S'$ by a series of swaps
of non- conflicting instructions, we say that $S$ and $S'$ are *conflict
equivalent*. We can swap only _adjacent_ operations.

The concept of conflict equivalence leads to the concept of conflict
serializability. We say that a schedule $S$ is *conflict serializable* if it is
conflict equivalent to a serial schedule. 

=== Serializability graph

Simple and efficient method for determining the conflict
seriazability of a schedule. Consider a schedule $S$. We construct a directed
graph, called a precedence graph, from $S$. The set of vertices
consists of all the transactions participating in the schedule. The set of
edges consists of all edges $T_i arrow T_j$ for which one of three conditions holds:

+ $T_i$ executes `write(Q)` before $T_j$ executes `read(Q)`.
+ $T_i$ executes `read(Q)` before $T_j$ executes `write(Q)`.
+ $T_i$ executes `write(Q)` before $T_j$ executes `write(Q)`.

If the precedence graph for $S$ has a cycle, then schedule $S$ is not conflict
serializable. If the graph contains no cycles, then the schedule $S$ is
conflict serializable.

== Standard isolation levels

- *Serializable* usually ensures serializable execution.
- *Repeatable* read allows only committed data to be read and further requires that,
  between two reads of a data item by a transaction, no other transaction is allowed
  to update it. However, the transaction may not be serializable
- *Read committed* allows only committed data to be read, but does not require re- peatable reads. 
- *Read uncommitted* allows uncommitted data to be read. Lowest isolation level allowed by SQL.

== Schedule

We say that a schedule S is *legal* under a given locking protocol if S is a possible
schedule for a set of transactions that follows the rules of the locking protocol. We say
that a locking protocol ensures conflict serializability if and only if all legal schedules
are *conflict serializable*; in other words, for all legal schedules the associated →relation
is acyclic.

== Protocols

=== Lock-based

==== Dealock

*Deadlock* is a condition where two or more tasks are each waiting for the
other to release a resource, or more than two tasks are waiting for resources
in a circular chain.

==== Starvation

*Starvation* (also known as indefinite blocking) occurs when a process or
thread is perpetually denied necessary resources to process its work. Unlike
deadlock, where everything halts, starvation only affects some while others
progress.

=== Timestamp-based

=== Validation-based

=== Version isolation

= Logs

== WAL principle

*Write Ahead Logging* -- Any change to data (update, delete, insert) must be
recorded in the log before the actual data is written to the disk. This ensures
that if the system crashes before the data pages are saved, the changes can
still be reconstructed from the log records during recovery.

== Recovery algorithm

In the *redo phase*, the system replays updates of all transactions by scanning
the log forward from the last checkpoint. The specific steps taken while
scanning the log are as follows:

+ The list of transactions to be rolled back, undo-list, is initially set to the list
   $L$ in the $<#[checkpoint] L>$ log record.
+ Whenever a normal log record of the form  $<T_i, X_j, V_1, V_2>$, or a redo-
  only log record of the form  $<T_i, X_j, V_2>$ is encountered, the operation is
  redone; that is, the value $V_2$ is written to data item $X_j$.
+ Whenever a log record of the form $<T_i #[start]>$ is found, $T_i$ is added to
  undo-list.
+ Whenever a log record of the form $<T_i #[abort]>$ or $<T_i #[commit]>$ is found,
  $T_i$ is removed from undo-list.

At the end of the redo phase, undo-list contains the list of all transactions that
are incomplete, that is, they neither committed nor completed rollback before the crash.
\ In the *undo phase*, the system rolls back all transactions in the undo-list.
It performs rollback by scanning the log backward from the end:

+ Whenever it finds a log record belonging to a transaction in the undo-list, it
  performs undo actions just as if the log record had been found during the
  rollback of a failed transaction.
+ When the system finds a $<T_i #[start]>$ log record for a transaction $T_i$ in undo-
  list, it writes a $<T_i #[abort]>$ log record to the log and removes $T_i$ from undo-
  list.
+ The undo phase terminates once undo-list becomes empty, that is, the system
  has found $<T_i #[start]>$ log records for all transactions that were initially
  in undo-list.

== Log types

- $<T_i, X_j, V_1, V_2>$ -- an update log record, indicating that transaction
  $T_i$ has performed a write on data item $X_j$. $X_j$ had value $V_1$ before
  the write and has value $V_2$ after the write. 
- $<T_i #[start]>$ -- $T_i$ has started.
- $<T_i #[commit]>$ -- $T_i$ has committed.
- $<T_i #[abort]>$ -- $T_i$ has aborted.

