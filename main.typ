#import "@preview/tablex:0.0.8": tablex, rowspanx, colspanx
#set page(margin: 0.6cm, columns: 3)
#set par(justify: true)
#set text(6pt)
#show heading: it => {
  if it.level == 1 {
    text(1em, upper(it))
  } else {
    text(1em, smallcaps(it))
  }
}

#set enum(numbering: "1aiA.")
= Indices

== Bitmap

Each bit in a bitmap corresponds to a possible item or condition, with a bit set
to 1 indicating presence or true, and a bit set to 0 indicating absence or
`false`.

#tablex(
  stroke: 0.5pt, columns: 4, [record number], `ID`, `gender`, `income_level`, `0`, `76766`, `m`, `L1`, `1`, `22222`, `f`, `L2`, `2`, `12121`, `f`, `L1`, `3`, `15151`, `m`, `L4`, `4`, `58583`, `f`, `L3`,
)
#grid(
  columns: 2, gutter: 2em, tablex(
    stroke: 0.5pt, columns: 2, colspanx(2)[Bitmaps for `gender`], `m`, `10010`, `f`, `01101`,
  ), tablex(
    stroke: 0.5pt, columns: 2, colspanx(2)[Bitmaps for `income_level`], `L1`, `10010`, `L2`, `01000`, `L3`, `00001`, `L4`, `00010`, `L5`, `00000`,
  ),
)

== B+ tree

*B+ tree* is a type of self-balancing tree data structure that maintains data
sorted and allows searches, sequential access, insertions, and deletions in
logarithmic time. It is an extension of the B-tree and is extensively used in
databases and filesystems for indexing. B+ tree is *Balanced*; Order (n):
Defined such that each node (except root) can have at most $n$ children
(pointers) and at least $ceil(n/2)$ children; *Internal nodes hold* between
$ceil(n/2)−1$ and $n−1$ keys (values); Leaf nodes hold between $ceil((n−1)/2)$ and
$n−1$ keys, but also store all data values corresponding to the keys; *Leaf
Nodes Linked*: Leaf nodes are linked together, making range queries and
sequential access very efficient.

- *Insert (key, data)*:
  - Insert key in the appropriate leaf node in sorted order;
  - If the node overflows (more than $n−1$ keys), split it, add the middle key to
    the parent, and adjust pointers;
    + Leaf split: $1$ to $ceil(n/2) $ and $ceil(n/2) + 1 $ to
      $n$ as two leafs. Promote the lowest from the 2nd one.
    + Node split: $1$ to $ceil((n+1)/2) - 1 $ and $ceil(n/2) + 1$ to $n$.
      $ceil(n+1/2)$ gets moved up.
  - If a split propagates to the root and causes the root to overflow, split the
    root and create a new root. Note: root can contain less than
    $ceil(n/2) - 1$ keys.
- *Delete (key)*:
  - Remove the key from the leaf node.
  - If the node underflows (fewer than $ceil(n/2)−1$ keys), keys and pointers are
    redistributed or nodes are merged to maintain minimum occupancy.
  Adjustments may propagate up to ensure all properties are maintained.

== Hash-index

*Hash indices* are a type of database index that uses a hash function to compute
the location (hash value) of data items for quick retrieval. They are
particularly efficient for equality searches that match exact values.

*Hash Function*: A hash function takes a key (a data item's attribute used for
indexing) and converts it into a hash value. This hash value determines the
position in the hash table where the corresponding record's pointer is stored.
*Hash Table*: The hash table stores pointers to the actual data records in the
database. Each entry in the hash table corresponds to a potential hash value
generated by the hash function.

= Algorithms

== Nested-loop join

*Nested Loop Join*: A nested loop join is a database join operation where each
tuple of the outer table is compared against every tuple of the inner table to
find all pairs of tuples which satisfy the join condition. This method is simple
but can be inefficient for large datasets due to its high computational cost.

```python
Simplified version (to get the idea)
for each tuple tr in r: (for each tuple ts in s: test pair (tr, ts))
```

// TODO: Add seek information
Block transfer cost: $n_r dot b_s + b_r$ block transfers would be required,
where $b_r$ -- blocks in relation $r$, same for $s$.

== Block-nested join

*Block Nested Loop Join*: A block nested loop join is an optimized version of
the nested loop join that reads and holds a block of rows from the outer table
in memory and then loops through the inner table, reducing the number of disk
accesses and improving performance over a standard nested loop join, especially
when indices are not available.

```python
Simplified version (to get the idea)
for each block Br of r: for each block Bs of s:
  for each tuple tr in r: (for each tuple ts in s: test pair (tr, ts))
```

// TODO: Add seek information
Block transfer cost: $b_r dot b_s + b_r$, $b_r$ -- blocks in relation $r$, same
for $s$.

== Merge join

*Merge Join*: A merge join is a database join operation where both the outer and
inner tables are first sorted on the join key, and then merged together by
sequentially scanning through both tables to find matching pairs. This method is
highly efficient when the tables are *already sorted* or can be *sorted
quickly*, minimizes random disk access. Merge-join method is efficient; the
number of block transfers is equal to the sum of the number of blocks in both
files, $b_r + b_s$. Assuming that $b_b$ buffer blocks are allocated to each
relation, the number of disk seeks required would be $ceil(b_r/b_b) + ceil(b_s/b_b)$ disk
seeks

+ Sort Both Tables: If not already sorted, the outer table and the inner table are
  sorted based on the join keys.
+ Merge: Once both tables are sorted, the algorithm performs a merging operation
  similar to that used in merge sort:
  + Begin with the first record of each table.
  + Compare the join keys of the current records from both tables.
    + If the keys match, join the records and move to the next record in both tables.
    + If the join key of the outer table is smaller, move to the next record in the
      outer table.
    + If the join key of the inner table is smaller, move to the next record in the
      inner table.
  + Continue this process until all records in either table have been examined.
+ Output the Joined Rows;

== Hash-join

*Hash Join*: A hash join is a database join operation that builds an in-memory
hash table using the join key from the smaller, often called the build table,
and then probes this hash table using the join key from the larger, or probe
table, to find matching pairs. This technique is very efficient for *large
datasets* where *indexes are not present*, as it reduces the need for nested
loops.

- $h$ is a hash function mapping JoinAttrs values to ${0, 1, ... , n_h}$, where
  JoinAttrs denotes the common attributes of $r$ and $s$ used in the natural join.
- $r_0, r_1, ..., r_n_h$ denote partitions of $r$ tuples, each initially empty.
  Each tuple $t_r in r$ is put in partition $r_i$, where $i = h(t_r ["JoinAttrs"])$.
- $s_0$, $s_1$, ..., $s_n_h$ denote partitions of s tuples, each initially empty.
  Each tuple $t_s in s$ is put in partition $s_i$, where $i = h(t_s ["JoinAttrs"])$.

Cost of block transfers: $3(b_r + b_s) + 4 n_h$. The hash join thus requires
$2(ceil(b_r/b_b) + ceil(b_s/b_b))+ 2n_h$ seeks.

$b_b$ blocks are allocated for the input buffer and each output buffer.

+ Build Phase:
  + Choose the smaller table (to minimize memory usage) as the "build table."
  + Create an in-memory hash table. For each record in the build table, compute a
    hash on the join key and insert the record into the hash table using this hash
    value as an index.
+ Probe Phase:
  + Take each record from the larger table, which is often referred to as the
    "probe table."
  + Compute the hash on the join key (same hash function used in the build phase).
  + Use this hash value to look up in the hash table built from the smaller table.
  + If the bucket (determined by the hash) contains any entries, check each entry to
    see if the join key actually matches the join key of the record from the probe
    table (since hash functions can lead to collisions).
+ Output the Joined Rows.

= Relational-algebra

== Equivalence rules

+ $ sigma_(theta_1 and theta_2)(E) = sigma_theta_1(sigma_theta_2(E)) $
+ $ sigma_theta_1(sigma_theta_2(E)) = sigma_theta_2(sigma_theta_1(E)) $
+ $ Pi_L_1(Pi_L_2(...(Pi_L_n (E))...)) = Pi_L_1(E) $ -- only the last one matters.
+ Selections can be combined with Cartesian products and theta joins:
  $ sigma_theta (E_1 times E_2) = E_1 join_theta E_2 $
  $ sigma_theta_1 (E_1 join_theta_2 E_2) = E_1 join_theta_1 and theta_2 E_2 $
+ $ E_1 join_theta E_2 = E_2 join_theta E_1 $
+ Join associativity: $ (E_1 join E_2) join E_3 = E_1 join (E_2 join E_3) $
  $ (E_1 join_theta_1 E_2) join_(theta_2 and theta_3) E_3 = E_1 join_(theta_1 and theta_3) (E_2 join_theta_2 E_3) $
+ Selection distribution:
  $ sigma_theta_1 (E_1 join_theta E_2) = (sigma_theta_0(E_1)) join_theta E_2 $
  $ sigma_(theta_1 and theta_2)(E_1 join_theta E_2) = (sigma_theta_1 (E)1)) join_theta (sigma_theta_2 (E_2)) $
+ Projection distribution:
  $ Pi_(L_1 union L_2) (E_1 join_theta E_2) = (Pi_L_1 (E_1) join_theta (Pi_L_2 (E_2))) $
  $ Pi_(L_1 union L_2) (E_1 join_theta E_2) = Pi_(L_1 union L_2) ((Pi_(L_1 union L_3) (E_1)) join_theta (Pi_(L_2 union L_4) (E_2))) $
+ Union and intersection commmutativity:
  $ E_1 union E_2 = E_2 union E_1 $
  $ E_1 sect E_2 = E_2 sect E_1 $
+ Set union and intersection are associative:
  $ (E_1 union E_2) union E_3 = E_1 union (E_2 union E_3) $
  $ (E_1 sect E_2) sect E_3 = E_1 sect (E_2 sect E_3) $
+ The selection operation distributes over the union, intersection, and
  set-difference operations:
  $ sigma_P (E_1 - E_2) = sigma_P (E_1) - E_2 = sigma_P (E_1) - sigma_P (E_2) $
+ The projection operation distributes over the union operation:
  $ Pi_L (E_1 union E_2) = (Pi_L (E_1)) union (Pi_L (E_2)) $

// FROM Database concepts

// == Operations
//
// - Projection ($pi$). Syntax: $pi_{#[attributes]}(R)$. Purpose: Reduces the
//   relation to only contain specified attributes. Example: $pi_{#[Name,
//   Age}]}(#[Employees])$
//
// - Selection ($sigma$). Syntax: $sigma_{#[condition]}(R)$. Purpose: Filters rows
//   that meet the condition. Example: $sigma_{#[Age] > 30}(#[Employees])$
//
// - Union ($union$). Syntax: $R union S$. Purpose: Combines tuples from both
//   relations, removing duplicates. Requirement: Relations must be
//   union-compatible.
//
// - Intersection ($sect$). Syntax: $R sect S$. Purpose: Retrieves tuples common
//   to both relations. Requirement: Relations must be union-compatible.
//
// - Difference ($-$). Syntax: $R - S$. Purpose: Retrieves tuples in R that are
//   not in S. Requirement: Relations must be union-compatible.
//
// - Cartesian Product ($times$). Syntax: $R times S$. Purpose: Combines tuples
//   from R with every tuple from S.
//
// - Natural Join ($join$). Syntax: $R join S$. Purpose: Combines tuples from R
//   and S based on common attribute values.
//
// - Theta Join ($join_theta$). Syntax: $R join_theta S$. Purpose: Combines tuples
//   from R and S where the theta condition holds.
//
// - Full Outer Join: $R join.l.r S$. Left Outer Join: $R join.l S$.
//   Right Outer Join: $R join.r S$. Purpose: Extends join to include non-matching
//   tuples from one or both relations, filling with nulls.

= Concurrency

=== Conflict

We say that $I$ and $J$ conflict if they are operations by *different
transactions* on the *same data item*, and at least one of these instructions is
a *write* operation. For example:
- $I = #[`read(Q)`]$ , $J = #[`read(Q)`]$ -- Not a conflict;
- $I = #[`read(Q)`]$ , $J = #[`write(Q)`]$ -- Conflict;
- $I = #[`write(Q)`]$, $J = #[`read(Q)`]$ -- Conflict;
- $I = #[`write(Q)`]$, $J = #[`write(Q)`]$ -- Conflict.

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
of non-conflicting instructions, we say that $S$ and $S'$ are *conflict
equivalent*. We can swap only _adjacent_ operations.

The concept of conflict equivalence leads to the concept of conflict
serializability. We say that a schedule $S$ is *conflict serializable* if it is
conflict equivalent to a serial schedule.

=== Serializability graph

Simple and efficient method for determining the conflict seriazability of a
schedule. Consider a schedule $S$. We construct a directed graph, called a
precedence graph, from $S$. The set of vertices consists of all the transactions
participating in the schedule. The set of edges consists of all edges $T_i -> T_j$ for
which one of three conditions holds:

+ $T_i$ executes `write(Q)` before $T_j$ executes `read(Q)`.
+ $T_i$ executes `read(Q)` before $T_j$ executes `write(Q)`.
+ $T_i$ executes `write(Q)` before $T_j$ executes `write(Q)`.

If the precedence graph for $S$ has a cycle, then schedule $S$ is not conflict
serializable. If the graph contains no cycles, then the schedule $S$ is conflict
serializable.

== Standard isolation levels

- *Serializable* usually ensures serializable execution.
- *Repeatable* read allows only committed data to be read and further requires
  that, between two reads of a data item by a transaction, no other transaction is
  allowed to update it. However, the transaction may not be serializable
- *Read committed* allows only committed data to be read, but does not require re-
  peatable reads.
- *Read uncommitted* allows uncommitted data to be read. Lowest isolation level
  allowed by SQL.

== Protocols

We say that a schedule S is *legal* under a given locking protocol if S is a
possible schedule for a set of transactions that follows the rules of the
locking protocol. We say that a locking protocol ensures conflict
serializability if and only if all legal schedules are *conflict serializable*;
in other words, for all legal schedules the associated $->$ relation is acyclic.

=== Lock-based

*Shared Lock* -- If a transaction $T_i$ has obtained a shared-mode lock (denoted
by $S$) on item Q, then Ti can read, but cannot write, $Q$.

*Exclusive Lock* -- If a transaction $T_i$ has obtained an exclusive-mode lock
(denoted by $X$) on item Q, then Ti can both read and write $Q$.

==== 2-phased lock protocol

*The Two-Phase Locking (2PL)* Protocol is a concurrency control method used in
database systems to ensure serializability of transactions. The protocol
involves two distinct phases: *Locking Phase (Growing Phase):* A transaction may
acquire locks but cannot release any locks. During this phase, the transaction
continues to lock all the resources (data items) it needs to execute.

*Unlocking Phase (Shrinking Phase):* The transaction releases locks and cannot
acquire any new ones. Once a transaction starts releasing locks, it moves into
this phase until all locks are released.

==== Problems of locks

*Deadlock* is a condition where two or more tasks are each waiting for the other
to release a resource, or more than two tasks are waiting for resources in a
circular chain.

*Starvation* (also known as indefinite blocking) occurs when a process or thread
is perpetually denied necessary resources to process its work. Unlike deadlock,
where everything halts, starvation only affects some while others progress.

=== Timestamp-based

*Timestamp Assignment:* Each transaction is given a unique timestamp when it
starts. This timestamp determines the transaction's temporal order relative to
others. *Read Rule:* A transaction can read an object if the last write occurred
by a transaction with an earlier or the same timestamp. *Write Rule:* A
transaction can write to an object if the last read and the last write occurred
by transactions with earlier or the same timestamps.

=== Validation-based

Assumes that conflicts are rare and checks for them only at the end of a
transaction. *Working Phase:* Transactions execute without acquiring locks,
recording all data reads and writes. *Validation Phase:* Before committing, each
transaction must validate that no other transactions have modified the data it
accessed. *Commit Phase:* If the validation is successful, the transaction
commits and applies its changes. If not, it rolls back and may be restarted.

// === Version isolation

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

+ The list of transactions to be rolled back, undo-list, is initially set to the
  list
  $L$ in the $<#[checkpoint] L>$ log record.
+ Whenever a normal log record of the form $<T_i, X_j, V_1, V_2>$, or a redo- only
  log record of the form $<T_i, X_j, V_2>$ is encountered, the operation is
  redone; that is, the value $V_2$ is written to data item $X_j$.
+ Whenever a log record of the form $<T_i #[start]>$ is found, $T_i$ is added to
  undo-list.
+ Whenever a log record of the form $<T_i #[abort]>$ or $<T_i #[commit]>$ is
  found,
  $T_i$ is removed from undo-list.

At the end of the redo phase, undo-list contains the list of all transactions
that are incomplete, that is, they neither committed nor completed rollback
before the crash.

In the *undo phase*, the system rolls back all transactions in the undo-list. It
performs rollback by scanning the log backward from the end:

+ Whenever it finds a log record belonging to a transaction in the undo-list, it
  performs undo actions just as if the log record had been found during the
  rollback of a failed transaction.
+ When the system finds a $<T_i #[start]>$ log record for a transaction $T_i$ in
  undo- list, it writes a $<T_i #[abort]>$ log record to the log and removes $T_i$ from
  undo- list.
+ The undo phase terminates once undo-list becomes empty, that is, the system has
  found $<T_i #[start]>$ log records for all transactions that were initially in
  undo-list.

== Log types

- $<T_i, X_j, V_1, V_2>$ -- an update log record, indicating that transaction
  $T_i$ has performed a write on data item $X_j$. $X_j$ had value $V_1$ before the
  write and has value $V_2$ after the write;
- $<T_i #[start]>$ -- $T_i$ has started;
- $<T_i #[commit]>$ -- $T_i$ has committed;
- $<T_i #[abort]>$ -- $T_i$ has aborted;
- $<#[checkpoint] {T_0, T_1, dots, T_n}>$ -- a checkpoint with a list of active
  transactions at the moment of checkpoint.

== Task
Pieņemsim, ka ir divas relācijas $r_1$ un $r_2$ ar atbilstošiem atribūtiem $r_1(A,B)$ un $r_2(B,C,D,E)$.
Relācijā $r_1$ ir $51105$ raksti, relācijā $r_2$ ir $320251$ raksti. Pieņemsim,
ka vienā blokā ietilpst $27$ relācijas $r_1$ raksti un $25$ relācijas $r_2$ raksti.
Relācijas tiek joinotas $(r_1 join r_2)$ izmantojot _block nested-loop join_ algoritmu.
Cik bloki ir minimālais atmiņas *apjoms $M$ (skaitlis!)*, lai būtu nepieciešams
ne vairāk kā
+ $130000$ bloku pārraides (transfers) no diska
+ $25000$ bloku pārraides (transfers) no diska

$ T=ceil(b_r/(M-2)) dot b_s+b_r ==> M approx ceil((b_s b_r)/(T-b_r))+2 $

$
  b_(r_1)=ceil(51105/27)=1893;
  b_(r_2)=ceil(320251/25)=12811
$

== Task
Pieņemsim, ka ir divas relācijas $r_1$ un $r_2$ ar atbilstošiem atribūtiem $r_1(A,B)$ un $r_2(B,C,D,E)$.
Relācijā $r_1$ ir $75435$ raksti, relācijai $r_2$ ir $11456$ raksti. Pieņemsim,
ka vienā blokā ietilpst $22$ relācijas $r_1$ raksti un $35$ relācijas $r_2$ raksti.
Pieņemsim, ka ir pieejami $5$ atmiņas bloki konkrētā algoritma izpildei. Viena
bloka pārraidei no diska nepieciešamas $0.001 "ms"$, bloka meklēšanai -- $0.1 "ms"$.
Uzrakstīt aprēķina formulas un savus pieņēmumus, kā arī aprēķināt skaitliski,
cik minimāli laika (ms) nepieciešams, lai izrēķinātu $r_1 join r_2$, izmantojot
_block join_ un _nested-loop join_. Neņemiet vērā laiku, ko prasa gala rezultāta
ierakstīšana diskā un neņemt vērā procesora laiku, kas patērēts šai operācijai.
Ņemt vērā tikai bloku meklēšanas un lasīšanas laikus.

===
$|r_1|=75435; |r_2|=11456$\
$b_r_1=22; b_r_2=35$\
$B=5;T_"disk"=0.001;T_"seek"=0.1$

=== Block Join method
+ *Memory Limitation*: Only 5 blocks available.
+ Blocks Needed for $r_1$ and $r_2$:
  - $r_1: ceil(75435/22)=3429$
  - $r_2: ceil(11456/35)=328$
+ *Strategy:*
  - Use 1 block for $r_1$ and 4 blocks for $r_2$ (or vice versa depending on which
    is more efficient).
  - This setup means you can have 4 blocks of $r_2$ loaded into memory, storing up
    to $4 dot 35=140$ patterns of $r_2$ at a time.
+ *Iterations Needed*:
  - *For $r_2$:* $ceil(11456/140)=82$ full iterations (each iteration loads $140$ patterns
    of $r_2$ into memory).
  - *For $r_1$:* Each block of $r_1$ needs to be loaded and processed against all
    loaded $r_2$ blocks for each iteration.
+ *Time Calculation for Block Join:*
  - Load time for $r_2$ per iteration: $4 dot 0.001 = 0.004 "ms"$
  - Total load time for $r_2$: $82 dot 0.004 = 0.328 "ms"$
  - Join Time per $r_1$ block per $r_2$ iteration: $0.1 "ms"$ (for each block of $r_1$ joined
    with 4 blocks of $r_2$)
  - Total join time for all $r_1$ blocks per $r_2$ iteration: $3429 dot 0.1= 342.9"ms"$
  - Total join time for all iterations: $343 dot 82 = 28117.8 "ms"$

=== Nested-Loop Join Method
+ Nested-loop join:
  - For each pattern in $r_1$, search all patterns in $r_2$.
+ Total Combinations: $75435 dot 11456=$
+ Time Calculation for Nested-Loop Join:
  - Reading and searching time for each combination: $0.001+0.1=0.101 "ms"$
  - Total time: $75435 dot 11456 dot 0.101 = 87282519.36 "ms"$
