/**
 * Generates sql/10_SEED_DSA_LEETCODE_TOP150.sql
 * Run: node generate_dsa_top150_seed.js
 */
const fs = require("fs");
const path = require("path");

function esc(s) {
  return String(s).replace(/'/g, "''");
}

function n(s) {
  return `N'${esc(s)}'`;
}

/** @typedef {{ key: string, name: string, tier: string, minutes: number, desc: string, theory: string, problems: Array<{title:string, slug:string, difficulty:string, summary:string, minutes:number}>, quizzes: Array<{q:string,a:string,b:string,c:string,d:string,correct:string,expl:string,diff:string}> }} Topic */

/** @type {Topic[]} */
const topics = [
  {
    key: "ARRAYS_STRINGS",
    name: "Arrays & Strings",
    tier: "BEGINNER",
    minutes: 90,
    desc:
      "Core array and string manipulations from the LeetCode Top Interview 150: in-place edits, prefix products, stock/greedy scans, and string parsing.",
    theory: `# Arrays & Strings (Interview Foundations)

## Why this topic
Most Top Interview 150 warm-ups are array/string problems. Interviewers use them to check **index discipline**, **in-place updates**, and **linear scans** before harder patterns.

## Core techniques
1. **Two-index write pointer** — Remove Element / Remove Duplicates: keep a \`write\` index for the next valid position while reading with \`i\`.
2. **Prefix / suffix products** — Product of Array Except Self: left products then right products without division; O(n) time, O(1) extra if output array is allowed.
3. **Single-pass greedy** — Best Time to Buy and Sell Stock: track \`minPrice\` and \`maxProfit\` in one left-to-right scan.
4. **Rotate / reverse blocks** — Rotate Array: reverse whole array, then reverse \`[0..k)\` and \`[k..n)\`.
5. **String scans** — Length of Last Word, Reverse Words, Longest Common Prefix: careful boundaries and early exits.

## Complexity targets
Aim for **O(n)** time and **O(1)** extra space unless the problem forces a map/set.

## Interview checklist
- Clarify mutation rules (in-place vs new array).
- Watch off-by-one at ends of rotations and reverses.
- State invariants of the write pointer before coding.`,
    problems: [
      { title: "Merge Sorted Array", slug: "merge-sorted-array", difficulty: "EASY", summary: "Merge nums2 into nums1 in-place from the back.", minutes: 20 },
      { title: "Remove Element", slug: "remove-element", difficulty: "EASY", summary: "Two-pointer write compaction for a target value.", minutes: 15 },
      { title: "Remove Duplicates from Sorted Array", slug: "remove-duplicates-from-sorted-array", difficulty: "EASY", summary: "Keep unique values with a slow write index.", minutes: 20 },
      { title: "Majority Element", slug: "majority-element", difficulty: "EASY", summary: "Boyer–Moore voting or sort + count.", minutes: 20 },
      { title: "Rotate Array", slug: "rotate-array", difficulty: "MEDIUM", summary: "Reverse-based rotation by k steps.", minutes: 25 },
      { title: "Best Time to Buy and Sell Stock", slug: "best-time-to-buy-and-sell-stock", difficulty: "EASY", summary: "Track min buy price and max profit.", minutes: 20 },
      { title: "Jump Game", slug: "jump-game", difficulty: "MEDIUM", summary: "Greedy farthest reach.", minutes: 25 },
      { title: "Product of Array Except Self", slug: "product-of-array-except-self", difficulty: "MEDIUM", summary: "Prefix × suffix without division.", minutes: 30 },
      { title: "Gas Station", slug: "gas-station", difficulty: "MEDIUM", summary: "Unique start index when total gas ≥ cost.", minutes: 30 },
      { title: "Trapping Rain Water", slug: "trapping-rain-water", difficulty: "HARD", summary: "Two pointers / pref max heights.", minutes: 40 },
      { title: "Roman to Integer", slug: "roman-to-integer", difficulty: "EASY", summary: "Subtractive notation scan.", minutes: 15 },
      { title: "Longest Common Prefix", slug: "longest-common-prefix", difficulty: "EASY", summary: "Vertical or horizontal scan.", minutes: 15 },
      { title: "Reverse Words in a String", slug: "reverse-words-in-a-string", difficulty: "MEDIUM", summary: "Trim, split, reverse word order.", minutes: 25 },
    ],
    quizzes: [
      {
        q: "For Remove Element / Remove Duplicates (sorted), what is the purpose of a separate write index?",
        a: "It marks the next position where a kept value should be written",
        b: "It stores the majority element candidate",
        c: "It computes prefix products",
        d: "It finds the pivot in a rotated array",
        correct: "A",
        expl: "You read with one pointer and compact kept elements via write++ so the prefix [0..write) is the answer.",
        diff: "EASY",
      },
      {
        q: "Product of Array Except Self without division is typically solved by:",
        a: "Sorting then multiplying neighbors",
        b: "Left prefix products combined with right suffix products",
        c: "Binary search on the product",
        d: "Kadane on the absolute values",
        correct: "B",
        expl: "answer[i] = product(left of i) × product(right of i).",
        diff: "MEDIUM",
      },
      {
        q: "In Best Time to Buy and Sell Stock (one transaction), which state is sufficient?",
        a: "All pairs i < j compared in O(n²)",
        b: "Running minimum price so far and best profit so far",
        c: "A monotonic decreasing stack of indices only",
        d: "Union-Find of price levels",
        correct: "B",
        expl: "Sell today against the cheapest buy seen earlier.",
        diff: "EASY",
      },
      {
        q: "Jump Game: why can greedy farthest-reach work in O(n)?",
        a: "Because jumps form a DAG with unique topological order",
        b: "Because the reachable interval from the start expands monotonically left→right",
        c: "Because the array is always sorted",
        d: "Because DP memoization is O(1) amortized",
        correct: "B",
        expl: "Track the max index reachable; if you pass it before n-1, you fail.",
        diff: "MEDIUM",
      },
      {
        q: "Rotate Array by k using three reverses is correct because:",
        a: "Reversals commute with sorting",
        b: "It realizes the cyclic shift identity via block reversals",
        c: "It uses O(k) extra memory only",
        d: "It requires the array to be strictly increasing",
        correct: "B",
        expl: "Classic reverse-whole then reverse two parts implements rotation in O(n) time / O(1) space.",
        diff: "MEDIUM",
      },
    ],
  },
  {
    key: "TWO_POINTERS",
    name: "Two Pointers",
    tier: "BEGINNER",
    minutes: 75,
    desc:
      "Paired indices moving toward each other or in the same direction—Top 150 classics like Two Sum II, 3Sum, Container With Most Water, and Valid Palindrome.",
    theory: `# Two Pointers

## Pattern
Maintain two indices (\`L\`, \`R\` or \`slow\`, \`fast\`) with a clear **invariant** so each move eliminates candidates.

## Variants in Top 150
- **Opposite ends** — Container With Most Water, Two Sum II (sorted): move the pointer that can improve the objective.
- **Same direction** — Is Subsequence: advance pattern pointer only on matches.
- **Sorted 3Sum** — Sort, fix \`i\`, then two-sum on the right with skip-duplicates.
- **Palindrome** — Valid Palindrome: skip non-alnum, compare case-insensitive.

## When not to use
Unsorted pairs needing arbitrary lookups → prefer **hash map**. Non-contiguous subsequences with more complex costs → DP.

## Complexity
Usually **O(n)** or **O(n log n)** if you sort first (3Sum).`,
    problems: [
      { title: "Valid Palindrome", slug: "valid-palindrome", difficulty: "EASY", summary: "Two pointers skipping non-alphanumeric.", minutes: 20 },
      { title: "Is Subsequence", slug: "is-subsequence", difficulty: "EASY", summary: "Advance pattern pointer on matches.", minutes: 15 },
      { title: "Two Sum II - Input Array Is Sorted", slug: "two-sum-ii-input-array-is-sorted", difficulty: "MEDIUM", summary: "Opposite ends on a sorted array.", minutes: 20 },
      { title: "Container With Most Water", slug: "container-with-most-water", difficulty: "MEDIUM", summary: "Maximize min(height)*width greedily.", minutes: 25 },
      { title: "3Sum", slug: "3sum", difficulty: "MEDIUM", summary: "Sort + fix i + two pointers; skip duplicates.", minutes: 35 },
    ],
    quizzes: [
      {
        q: "On a sorted array, Two Sum II moves pointers based on:",
        a: "Hash collisions",
        b: "Whether current sum is less/greater than target",
        c: "Random sampling",
        d: "BFS layers",
        correct: "B",
        expl: "Increase L if sum too small; decrease R if sum too large.",
        diff: "EASY",
      },
      {
        q: "In Container With Most Water, why move the shorter line inward?",
        a: "Width always increases that way",
        b: "Height is fixed by the shorter line; only a taller candidate can improve area",
        c: "It guarantees a local maximum only",
        d: "Because the array must be bitonic",
        correct: "B",
        expl: "Area = min(hL,hR)*(R-L); moving the taller side cannot increase min height.",
        diff: "MEDIUM",
      },
      {
        q: "3Sum after sorting uses two pointers primarily to:",
        a: "Avoid O(n³) while handling duplicates carefully",
        b: "Replace sorting entirely",
        c: "Compute FFT convolution",
        d: "Build a segment tree",
        correct: "A",
        expl: "Fix one index, solve two-sum on the remainder in linear time; skip equal values.",
        diff: "MEDIUM",
      },
      {
        q: "Is Subsequence two-pointer approach advances the pattern index when:",
        a: "Characters mismatch",
        b: "Characters match",
        c: "Indices are equal",
        d: "The text is sorted",
        correct: "B",
        expl: "Only matches consume the next required character of the pattern.",
        diff: "EASY",
      },
    ],
  },
  {
    key: "SLIDING_WINDOW",
    name: "Sliding Window",
    tier: "INTERMEDIATE",
    minutes: 80,
    desc:
      "Contiguous subarray/substring constraints: Minimum Size Subarray Sum, Longest Substring Without Repeating Characters, and Minimum Window Substring from Top 150.",
    theory: `# Sliding Window

## Idea
Maintain a window \`[L, R]\` over a contiguous range. Expand \`R\` to include candidates; shrink \`L\` when a constraint is violated or when optimizing.

## Top 150 exemplars
- **Minimum Size Subarray Sum** — expand until sum ≥ target, then shrink for minimal length (positive numbers).
- **Longest Substring Without Repeating Characters** — window with last-seen index / count map.
- **Minimum Window Substring** — need-count map; shrink when all required chars are satisfied.

## Fixed vs variable
Fixed size updates aggregates in O(1) per step. Variable size needs a clear **validity predicate**.

## Pitfalls
- Off-by-one on inclusive bounds.
- Forgetting to update the map when shrinking.
- Applying positive-sum shrink logic to arrays with negatives (won't work).`,
    problems: [
      { title: "Minimum Size Subarray Sum", slug: "minimum-size-subarray-sum", difficulty: "MEDIUM", summary: "Shortest subarray with sum ≥ target (positives).", minutes: 30 },
      { title: "Longest Substring Without Repeating Characters", slug: "longest-substring-without-repeating-characters", difficulty: "MEDIUM", summary: "Window + last index / frequency map.", minutes: 30 },
      { title: "Substring with Concatenation of All Words", slug: "substring-with-concatenation-of-all-words", difficulty: "HARD", summary: "Word-size sliding windows + maps.", minutes: 45 },
      { title: "Minimum Window Substring", slug: "minimum-window-substring", difficulty: "HARD", summary: "Smallest window covering all of t.", minutes: 45 },
    ],
    quizzes: [
      {
        q: "Variable sliding window is preferred when:",
        a: "You need contiguous subarrays/substrings with a maintainable constraint",
        b: "The array is a binary tree",
        c: "You must process non-contiguous subsequences only",
        d: "n ≤ 5 always",
        correct: "A",
        expl: "Amortized O(n) when each index enters/leaves the window at most once.",
        diff: "EASY",
      },
      {
        q: "Minimum Size Subarray Sum (positive integers) shrinks L when:",
        a: "sum < target",
        b: "sum ≥ target (to minimize length)",
        c: "R reaches n",
        d: "A duplicate appears",
        correct: "B",
        expl: "Once valid, shrink to find the shortest valid window ending at R.",
        diff: "MEDIUM",
      },
      {
        q: "Longest Substring Without Repeating Characters typically stores:",
        a: "A segment tree of ASCII",
        b: "Counts or last-seen indices of characters in the current window",
        c: "Union-Find of characters",
        d: "A priority queue of lengths",
        correct: "B",
        expl: "Detect duplicates inside the window in O(1) per character.",
        diff: "EASY",
      },
      {
        q: "Minimum Window Substring needs a 'formed' counter to:",
        a: "Count total characters in s only",
        b: "Know when every required character type meets its needed frequency",
        c: "Sort t",
        d: "Hash the entire string s",
        correct: "B",
        expl: "Shrink only while the window remains 'valid' (all needs satisfied).",
        diff: "HARD",
      },
    ],
  },
  {
    key: "HASH_MAP",
    name: "Hash Map",
    tier: "BEGINNER",
    minutes: 70,
    desc:
      "Frequency maps, indexing, and O(1) lookups: Two Sum, Group Anagrams, Happy Number, Contains Duplicate II, Longest Consecutive Sequence.",
    theory: `# Hash Map

## Role in interviews
Trade space for average **O(1)** insert/lookup. Many Top 150 “easy/medium” problems become trivial with a map.

## Patterns
- **Complement lookup** — Two Sum: store value→index; query \`target - x\`.
- **Canonical key** — Group Anagrams: sorted string or 26-count signature as key.
- **Windowed index map** — Contains Duplicate II: last index within distance k.
- **Set growth** — Longest Consecutive Sequence: put all in a set; only start chains from numbers without \`x-1\`.

## Complexity note
Average O(1); worst-case hashing rare in interviews—state the assumption.`,
    problems: [
      { title: "Ransom Note", slug: "ransom-note", difficulty: "EASY", summary: "Frequency of magazine covers note.", minutes: 15 },
      { title: "Isomorphic Strings", slug: "isomorphic-strings", difficulty: "EASY", summary: "Bijection via two maps or encode pattern.", minutes: 20 },
      { title: "Word Pattern", slug: "word-pattern", difficulty: "EASY", summary: "Bijection between pattern chars and words.", minutes: 20 },
      { title: "Valid Anagram", slug: "valid-anagram", difficulty: "EASY", summary: "Count array / map equality.", minutes: 15 },
      { title: "Group Anagrams", slug: "group-anagrams", difficulty: "MEDIUM", summary: "Hash by sorted key or count tuple.", minutes: 25 },
      { title: "Two Sum", slug: "two-sum", difficulty: "EASY", summary: "One-pass complement map.", minutes: 15 },
      { title: "Happy Number", slug: "happy-number", difficulty: "EASY", summary: "Seen set of sums of squares.", minutes: 20 },
      { title: "Contains Duplicate II", slug: "contains-duplicate-ii", difficulty: "EASY", summary: "Index map with distance ≤ k.", minutes: 20 },
      { title: "Longest Consecutive Sequence", slug: "longest-consecutive-sequence", difficulty: "MEDIUM", summary: "Set + start-of-chain expansion O(n).", minutes: 30 },
    ],
    quizzes: [
      {
        q: "Two Sum one-pass hash map stores:",
        a: "Only sorted unique values",
        b: "Value → index of numbers seen so far",
        c: "Prefix XOR only",
        d: "A Fenwick tree of indices",
        correct: "B",
        expl: "For each x, look up target−x before inserting x.",
        diff: "EASY",
      },
      {
        q: "Group Anagrams keys are equal iff:",
        a: "Strings have the same length only",
        b: "Strings share the same character multiset",
        c: "Strings are rotations",
        d: "Strings are palindromes",
        correct: "B",
        expl: "Sorted form or 26-letter count vector identifies anagram classes.",
        diff: "EASY",
      },
      {
        q: "Longest Consecutive Sequence achieves O(n) by:",
        a: "Sorting then scanning",
        b: "Only expanding sequences from numbers that have no predecessor in the set",
        c: "Segment trees over value range",
        d: "Dijkstra on a number graph",
        correct: "B",
        expl: "Each number is visited a constant number of times across all expansions.",
        diff: "MEDIUM",
      },
      {
        q: "Isomorphic Strings requires:",
        a: "A one-way mapping only from s→t",
        b: "A consistent bijection (no two letters mapping to the same target inconsistently)",
        c: "Both strings sorted",
        d: "Equal vowel counts only",
        correct: "B",
        expl: "Use two maps or ensure reverse mapping uniqueness.",
        diff: "MEDIUM",
      },
    ],
  },
  {
    key: "INTERVALS",
    name: "Intervals",
    tier: "INTERMEDIATE",
    minutes: 60,
    desc:
      "Sort-and-sweep interval problems: Summary Ranges, Merge Intervals, Insert Interval, and Minimum Number of Arrows to Burst Balloons.",
    theory: `# Intervals

## Standard pipeline
1. Sort by start (sometimes by end).
2. Sweep while merging overlaps or counting conflicts.

## Top 150
- **Merge Intervals** — if \`cur.start ≤ last.end\`, merge ends; else push new.
- **Insert Interval** — linear scan: add before, merge overlapping, append after.
- **Minimum Arrows** — sort by end; greedy shoot at end of current balloon cluster.

## Proof sketch (arrows)
Sorting by end and always shooting at the earliest finishing interval is optimal for covering intervals on a line.`,
    problems: [
      { title: "Summary Ranges", slug: "summary-ranges", difficulty: "EASY", summary: "Compress consecutive sorted numbers.", minutes: 15 },
      { title: "Merge Intervals", slug: "merge-intervals", difficulty: "MEDIUM", summary: "Sort by start; merge overlaps.", minutes: 25 },
      { title: "Insert Interval", slug: "insert-interval", difficulty: "MEDIUM", summary: "Insert then merge overlapping range.", minutes: 30 },
      { title: "Minimum Number of Arrows to Burst Balloons", slug: "minimum-number-of-arrows-to-burst-balloons", difficulty: "MEDIUM", summary: "Greedy by end points.", minutes: 30 },
    ],
    quizzes: [
      {
        q: "Merge Intervals first step is almost always:",
        a: "Sort intervals by start time",
        b: "Build a segment tree",
        c: "Hash all endpoints",
        d: "Run Dijkstra",
        correct: "A",
        expl: "Sorting enables a single linear merge pass.",
        diff: "EASY",
      },
      {
        q: "Two intervals [a,b] and [c,d] (a≤c) overlap when:",
        a: "b < c",
        b: "c ≤ b",
        c: "a == d",
        d: "Always",
        correct: "B",
        expl: "If the next start is ≤ current end, they intersect or touch (problem-dependent on touching).",
        diff: "EASY",
      },
      {
        q: "Minimum arrows greedy sorts by:",
        a: "Interval length ascending",
        b: "Ending coordinate ascending",
        c: "Starting coordinate descending",
        d: "Random order",
        correct: "B",
        expl: "Shoot at the end of the earliest-ending balloon still active.",
        diff: "MEDIUM",
      },
      {
        q: "Insert Interval can be done in one pass by:",
        a: "Only binary searching the middle",
        b: "Emitting non-overlapping left, merging overlap region, then appending right",
        c: "Always sorting after each insert only",
        d: "Using Union-Find on indices",
        correct: "B",
        expl: "Three phases over an already sorted list.",
        diff: "MEDIUM",
      },
    ],
  },
  {
    key: "STACK",
    name: "Stack",
    tier: "INTERMEDIATE",
    minutes: 75,
    desc:
      "LIFO structure for parsing and monotonic patterns: Valid Parentheses, Simplify Path, Min Stack, Evaluate Reverse Polish Notation, Basic Calculator.",
    theory: `# Stack

## Uses
- Matching delimiters (**Valid Parentheses**).
- Path normalization (**Simplify Path**).
- Postfix evaluation (**RPN**).
- Supporting O(1) min with an auxiliary stack (**Min Stack**).
- Expression parsing (**Basic Calculator**) with sign/stack frames.

## Monotonic stack (related Top 150)
Daily Temperatures / next greater: maintain increasing/decreasing indices so each element is pushed/popped once → O(n).

## Invariants
Top of stack is the nearest unresolved opener / candidate.`,
    problems: [
      { title: "Valid Parentheses", slug: "valid-parentheses", difficulty: "EASY", summary: "Stack of opening brackets.", minutes: 15 },
      { title: "Simplify Path", slug: "simplify-path", difficulty: "MEDIUM", summary: "Unix path with . and .. via stack.", minutes: 25 },
      { title: "Min Stack", slug: "min-stack", difficulty: "MEDIUM", summary: "Aux stack or encode mins.", minutes: 25 },
      { title: "Evaluate Reverse Polish Notation", slug: "evaluate-reverse-polish-notation", difficulty: "MEDIUM", summary: "Stack operands; apply operators.", minutes: 25 },
      { title: "Basic Calculator", slug: "basic-calculator", difficulty: "HARD", summary: "Signs and parentheses with a stack.", minutes: 40 },
    ],
    quizzes: [
      {
        q: "Valid Parentheses fails immediately when:",
        a: "You see a closing bracket that does not match stack top",
        b: "The string length is even",
        c: "There are only round brackets",
        d: "ASCII order is not sorted",
        correct: "A",
        expl: "Also fail if stack nonempty at end.",
        diff: "EASY",
      },
      {
        q: "Min Stack getMin in O(1) is achieved by:",
        a: "Scanning the whole stack each call",
        b: "Keeping a parallel structure of minima as elements are pushed",
        c: "Sorting on every push",
        d: "Hashing values only",
        correct: "B",
        expl: "Push current min alongside values (or store pairs).",
        diff: "MEDIUM",
      },
      {
        q: "RPN evaluation pushes numbers and on an operator:",
        a: "Pushes the operator",
        b: "Pops operands, applies operator, pushes result",
        c: "Clears the stack",
        d: "Converts to infix first",
        correct: "B",
        expl: "Classic postfix machine.",
        diff: "EASY",
      },
      {
        q: "Simplify Path treats '..' by:",
        a: "Appending '..' always",
        b: "Popping one directory level if the stack is non-empty",
        c: "Sorting segments",
        d: "Ignoring all segments",
        correct: "B",
        expl: "'.' is no-op; empty segments from '//' skipped.",
        diff: "MEDIUM",
      },
    ],
  },
  {
    key: "LINKED_LIST",
    name: "Linked List",
    tier: "INTERMEDIATE",
    minutes: 85,
    desc:
      "Pointer rewiring: reverse, merge, cycle detection, remove nth from end, rotate, partition, LRU Cache (design).",
    theory: `# Linked List

## Toolkit
- **Dummy head** — simplifies insert/delete at head.
- **Fast/slow** — middle, cycle detect (**Linked List Cycle**), cycle start.
- **Reverse** — iterative three pointers or recursion.
- **Merge** — Merge Two Sorted Lists / merge step of sort list.
- **Two-pass / gap** — Remove Nth Node From End with lead pointer.

## LRU Cache (Top 150 Design)
Hash map + doubly linked list: O(1) move-to-front and eviction.

## Safety
Always null-check; draw before/after pointer diagrams in interviews.`,
    problems: [
      { title: "Linked List Cycle", slug: "linked-list-cycle", difficulty: "EASY", summary: "Floyd fast/slow pointers.", minutes: 20 },
      { title: "Add Two Numbers", slug: "add-two-numbers", difficulty: "MEDIUM", summary: "Digit-wise sum with carry.", minutes: 25 },
      { title: "Merge Two Sorted Lists", slug: "merge-two-sorted-lists", difficulty: "EASY", summary: "Dummy head merge.", minutes: 20 },
      { title: "Copy List with Random Pointer", slug: "copy-list-with-random-pointer", difficulty: "MEDIUM", summary: "Map or interleaving copy.", minutes: 35 },
      { title: "Reverse Linked List II", slug: "reverse-linked-list-ii", difficulty: "MEDIUM", summary: "Reverse a sublist [left,right].", minutes: 30 },
      { title: "Reverse Nodes in k-Group", slug: "reverse-nodes-in-k-group", difficulty: "HARD", summary: "Reverse every k nodes.", minutes: 40 },
      { title: "Remove Nth Node From End of List", slug: "remove-nth-node-from-end-of-list", difficulty: "MEDIUM", summary: "Lead pointer by n.", minutes: 25 },
      { title: "Remove Duplicates from Sorted List II", slug: "remove-duplicates-from-sorted-list-ii", difficulty: "MEDIUM", summary: "Skip all nodes of duplicated values.", minutes: 30 },
      { title: "Rotate List", slug: "rotate-list", difficulty: "MEDIUM", summary: "Connect ring; break at new head.", minutes: 25 },
      { title: "Partition List", slug: "partition-list", difficulty: "MEDIUM", summary: "Two lists <x and ≥x then join.", minutes: 25 },
      { title: "LRU Cache", slug: "lru-cache", difficulty: "MEDIUM", summary: "HashMap + doubly linked list design.", minutes: 40 },
    ],
    quizzes: [
      {
        q: "Floyd’s cycle detection uses:",
        a: "A hash set only",
        b: "Fast pointer moving 2 steps and slow moving 1",
        c: "Binary lifting",
        d: "Morris traversal exclusively",
        correct: "B",
        expl: "They meet iff a cycle exists.",
        diff: "EASY",
      },
      {
        q: "Remove Nth From End in one pass uses a gap of n between pointers so that:",
        a: "The lead reaches null when the follower is at the node before the target",
        b: "Both start at the tail",
        c: "The list must be doubly linked",
        d: "n is always 1",
        correct: "A",
        expl: "Dummy head helps when deleting the original head.",
        diff: "MEDIUM",
      },
      {
        q: "LRU Cache needs a doubly linked list primarily to:",
        a: "Sort keys alphabetically",
        b: "Move a node to most-recent position and evict least-recent in O(1)",
        c: "Compute GCD of capacities",
        d: "Store only values without keys",
        correct: "B",
        expl: "Map gives O(1) node access; list orders recency.",
        diff: "MEDIUM",
      },
      {
        q: "Merge Two Sorted Lists invariant:",
        a: "Always append the larger head",
        b: "Always append the smaller current head of the two lists",
        c: "Randomly pick a head",
        d: "Reverse both lists first",
        correct: "B",
        expl: "Identical to merge step in merge sort.",
        diff: "EASY",
      },
    ],
  },
  {
    key: "BINARY_TREE",
    name: "Binary Tree",
    tier: "INTERMEDIATE",
    minutes: 100,
    desc:
      "DFS/BFS tree problems from Top 150: depth, same tree, invert, path sum, diameter, good nodes, LCA, flatten, max path sum.",
    theory: `# Binary Tree (General)

## Traversals
- **DFS** — preorder / inorder / postorder (recursion or explicit stack).
- **BFS** — level order with a queue (**Binary Tree Level Order Traversal**).

## Classic DP-on-tree
- **Diameter** — for each node, leftHeight + rightHeight; track global max.
- **Max Path Sum** — gain from child = max(0, childGain); combine carefully.
- **Path Sum** — remaining target down the path.

## Construction
Inorder + Preorder / Postorder: hash inorder indices; recurse on ranges.

## LCA
If root matches p or q, return root; combine left/right recursive results.`,
    problems: [
      { title: "Maximum Depth of Binary Tree", slug: "maximum-depth-of-binary-tree", difficulty: "EASY", summary: "DFS/BFS height.", minutes: 15 },
      { title: "Same Tree", slug: "same-tree", difficulty: "EASY", summary: "Structural and value equality.", minutes: 15 },
      { title: "Invert Binary Tree", slug: "invert-binary-tree", difficulty: "EASY", summary: "Swap children recursively.", minutes: 15 },
      { title: "Symmetric Tree", slug: "symmetric-tree", difficulty: "EASY", summary: "Mirror recursion / BFS pairs.", minutes: 20 },
      { title: "Construct Binary Tree from Preorder and Inorder Traversal", slug: "construct-binary-tree-from-preorder-and-inorder-traversal", difficulty: "MEDIUM", summary: "Hash inorder indices; recurse.", minutes: 35 },
      { title: "Construct Binary Tree from Inorder and Postorder Traversal", slug: "construct-binary-tree-from-inorder-and-postorder-traversal", difficulty: "MEDIUM", summary: "Root at postorder end.", minutes: 35 },
      { title: "Populating Next Right Pointers in Each Node II", slug: "populating-next-right-pointers-in-each-node-ii", difficulty: "MEDIUM", summary: "Level links without perfect tree assumption.", minutes: 35 },
      { title: "Flatten Binary Tree to Linked List", slug: "flatten-binary-tree-to-linked-list", difficulty: "MEDIUM", summary: "Preorder flatten in-place.", minutes: 30 },
      { title: "Path Sum", slug: "path-sum", difficulty: "EASY", summary: "Root-to-leaf remaining sum.", minutes: 20 },
      { title: "Sum Root to Leaf Numbers", slug: "sum-root-to-leaf-numbers", difficulty: "MEDIUM", summary: "Accumulate digit paths.", minutes: 25 },
      { title: "Binary Tree Maximum Path Sum", slug: "binary-tree-maximum-path-sum", difficulty: "HARD", summary: "Node-centered path DP.", minutes: 40 },
      { title: "Binary Tree Level Order Traversal", slug: "binary-tree-level-order-traversal", difficulty: "MEDIUM", summary: "BFS by levels.", minutes: 20 },
      { title: "Average of Levels in Binary Tree", slug: "average-of-levels-in-binary-tree", difficulty: "EASY", summary: "BFS averages.", minutes: 15 },
      { title: "Binary Tree Zigzag Level Order Traversal", slug: "binary-tree-zigzag-level-order-traversal", difficulty: "MEDIUM", summary: "Alternate direction per level.", minutes: 25 },
      { title: "Minimum Absolute Difference in BST", slug: "minimum-absolute-difference-in-bst", difficulty: "EASY", summary: "Inorder adjacent diffs.", minutes: 20 },
      { title: "Kth Smallest Element in a BST", slug: "kth-smallest-element-in-a-bst", difficulty: "MEDIUM", summary: "Inorder count / Morris.", minutes: 25 },
      { title: "Validate Binary Search Tree", slug: "validate-binary-search-tree", difficulty: "MEDIUM", summary: "Bounds or inorder increasing.", minutes: 25 },
      { title: "Lowest Common Ancestor of a Binary Tree", slug: "lowest-common-ancestor-of-a-binary-tree", difficulty: "MEDIUM", summary: "Postorder combine sides.", minutes: 30 },
    ],
    quizzes: [
      {
        q: "Maximum depth of a binary tree equals:",
        a: "Number of nodes",
        b: "1 + max(depth(left), depth(right)) (null → 0)",
        c: "Width of the last level",
        d: "Inorder length",
        correct: "B",
        expl: "Standard recursive height definition.",
        diff: "EASY",
      },
      {
        q: "Validate BST must enforce:",
        a: "Only left < root and right > root locally without ranges",
        b: "All keys in left subtree < root < all keys in right subtree (bounds)",
        c: "Perfect balance",
        d: "Heap order",
        correct: "B",
        expl: "Local checks miss transitive violations; pass (min,max) bounds.",
        diff: "MEDIUM",
      },
      {
        q: "Level-order traversal uses:",
        a: "A stack exclusively",
        b: "A queue (BFS)",
        c: "Union-Find",
        d: "Dijkstra",
        correct: "B",
        expl: "Process nodes level by level.",
        diff: "EASY",
      },
      {
        q: "Binary Tree Maximum Path Sum allows the path to:",
        a: "Only go root-to-leaf",
        b: "Bend at a node using both children contributions (with careful gains)",
        c: "Only use right children",
        d: "Skip the root always",
        correct: "B",
        expl: "Global answer can bend; return value to parent uses at most one child gain.",
        diff: "HARD",
      },
      {
        q: "Construct tree from preorder+inorder: the preorder first element is:",
        a: "Always a leaf",
        b: "The subtree root; inorder split defines left/right sizes",
        c: "The maximum value",
        d: "Irrelevant",
        correct: "B",
        expl: "Hash inorder positions to get O(n) construction.",
        diff: "MEDIUM",
      },
    ],
  },
  {
    key: "GRAPH",
    name: "Graphs",
    tier: "ADVANCED",
    minutes: 95,
    desc:
      "Adjacency, BFS/DFS, islands, cloning, courses (topo), snaking word search, and evaluate division from Top 150.",
    theory: `# Graphs

## Representations
Adjacency list for sparse graphs; matrix for dense / grid.

## Algorithms in Top 150
- **Number of Islands** — DFS/BFS flood fill on grid.
- **Clone Graph** — hash old→new while DFS/BFS.
- **Course Schedule / II** — cycle detect / Kahn topological sort.
- **Surrounded Regions** — mark border-connected 'O's then flip.
- **Word Ladder** — BFS on implicit word graph (shortest transformation).

## Topo sort tip
Indegree queue (Kahn) or DFS coloring (0/1/2) for cycles.

## Complexity
V nodes, E edges: BFS/DFS **O(V+E)**.`,
    problems: [
      { title: "Number of Islands", slug: "number-of-islands", difficulty: "MEDIUM", summary: "DFS/BFS flood fill on grid.", minutes: 25 },
      { title: "Surrounded Regions", slug: "surrounded-regions", difficulty: "MEDIUM", summary: "Border DFS then flip.", minutes: 30 },
      { title: "Clone Graph", slug: "clone-graph", difficulty: "MEDIUM", summary: "Map + DFS/BFS copy.", minutes: 30 },
      { title: "Evaluate Division", slug: "evaluate-division", difficulty: "MEDIUM", summary: "Weighted graph / UF with ratios.", minutes: 35 },
      { title: "Course Schedule", slug: "course-schedule", difficulty: "MEDIUM", summary: "Detect cycle in directed graph.", minutes: 30 },
      { title: "Course Schedule II", slug: "course-schedule-ii", difficulty: "MEDIUM", summary: "Return a valid topological order.", minutes: 30 },
      { title: "Snakes and Ladders", slug: "snakes-and-ladders", difficulty: "MEDIUM", summary: "BFS on board graph.", minutes: 35 },
      { title: "Minimum Genetic Mutation", slug: "minimum-genetic-mutation", difficulty: "MEDIUM", summary: "BFS word mutations.", minutes: 30 },
      { title: "Word Ladder", slug: "word-ladder", difficulty: "HARD", summary: "Shortest transformation BFS.", minutes: 40 },
    ],
    quizzes: [
      {
        q: "Number of Islands counts components by:",
        a: "Sorting all cells",
        b: "Flood-filling each unvisited land cell and incrementing once per component",
        c: "Union of all water cells",
        d: "Dijkstra from (0,0)",
        correct: "B",
        expl: "Each DFS/BFS from a '1' marks one island.",
        diff: "EASY",
      },
      {
        q: "Course Schedule is impossible when the prerequisite graph has:",
        a: "Any undirected edge",
        b: "A directed cycle",
        c: "More than 10 nodes",
        d: "Multiple connected components",
        correct: "B",
        expl: "A cycle means circular prerequisites.",
        diff: "MEDIUM",
      },
      {
        q: "Kahn’s algorithm for topo sort repeatedly:",
        a: "Removes nodes with indegree 0",
        b: "Removes nodes with highest degree",
        c: "DFS only",
        d: "Sorts edges by weight",
        correct: "A",
        expl: "If not all nodes processed, a cycle exists.",
        diff: "MEDIUM",
      },
      {
        q: "Word Ladder finds shortest transformation using:",
        a: "DFS with random restarts",
        b: "BFS on the implicit graph of one-letter mutations",
        c: "Dijkstra with negative weights",
        d: "Binary search on string length",
        correct: "B",
        expl: "Unweighted shortest path → BFS.",
        diff: "MEDIUM",
      },
    ],
  },
  {
    key: "TRIE",
    name: "Trie",
    tier: "ADVANCED",
    minutes: 55,
    desc:
      "Prefix trees for Implement Trie and word search / design add-and-search from Top 150.",
    theory: `# Trie (Prefix Tree)

## Structure
Each edge is a character; node flags \`isEnd\`. Optional children array[26] or hash map.

## Operations
- Insert / Search / StartsWith — O(L) in word length.
- **Design Add and Search Words** — DFS on '.' wildcards.
- **Word Search II** — backtracking on board pruned by trie (and delete leaves for speed).

## Why interviews love it
Shows pointer/structure design and pruning intuition.`,
    problems: [
      { title: "Implement Trie (Prefix Tree)", slug: "implement-trie-prefix-tree", difficulty: "MEDIUM", summary: "insert / search / startsWith.", minutes: 30 },
      { title: "Design Add and Search Words Data Structure", slug: "design-add-and-search-words-data-structure", difficulty: "MEDIUM", summary: "Wildcard '.' via DFS.", minutes: 35 },
      { title: "Word Search II", slug: "word-search-ii", difficulty: "HARD", summary: "Board DFS pruned by trie.", minutes: 45 },
    ],
    quizzes: [
      {
        q: "Trie startsWith is efficient because:",
        a: "It sorts all words first",
        b: "It walks only the prefix path of length L",
        c: "It uses binary search on suffixes",
        d: "It hashes the entire dictionary each call",
        correct: "B",
        expl: "O(L) independent of dictionary size (for fixed alphabet).",
        diff: "EASY",
      },
      {
        q: "In Word Search II, a trie helps by:",
        a: "Replacing the board",
        b: "Pruning DFS paths that cannot match any remaining word",
        c: "Sorting the board rows",
        d: "Guaranteeing O(1) DFS",
        correct: "B",
        expl: "Only follow edges that exist in the trie.",
        diff: "HARD",
      },
      {
        q: "Search with '.' in a trie requires:",
        a: "Only following one child always",
        b: "Branching DFS over all children at that position",
        c: "Converting to a suffix array",
        d: "Ignoring the rest of the pattern",
        correct: "B",
        expl: "Wildcard matches any character edge.",
        diff: "MEDIUM",
      },
      {
        q: "A trie node typically stores:",
        a: "Only the full word string",
        b: "Children map/array and an end-of-word flag",
        c: "A priority queue",
        d: "Graph edge weights",
        correct: "B",
        expl: "Minimal fields for insert/search/prefix.",
        diff: "EASY",
      },
    ],
  },
  {
    key: "BACKTRACKING",
    name: "Backtracking",
    tier: "ADVANCED",
    minutes: 80,
    desc:
      "Explore/build/retract: Letter Combinations, Combinations, Permutations, Combination Sum, N-Queens, Word Search, Generate Parentheses.",
    theory: `# Backtracking

## Template
\`\`\`
def dfs(path, state):
  if goal: record(path); return
  for choice in options:
    if invalid(choice): continue
    apply(choice); dfs(...); undo(choice)
\`\`\`

## Top 150 themes
- **Combinations / Permutations** — index start vs used[] array.
- **Combination Sum** — reuse allowed → pass same \`i\`; unlimited candidates sorted for prune.
- **N-Queens** — column/diag bitsets.
- **Word Search** — mark visited cell; four directions.
- **Generate Parentheses** — track open/close counts.

## Pruning
Sort + break when candidate > remain; bitmasks for queens.`,
    problems: [
      { title: "Letter Combinations of a Phone Number", slug: "letter-combinations-of-a-phone-number", difficulty: "MEDIUM", summary: "DFS over digit→letters map.", minutes: 25 },
      { title: "Combinations", slug: "combinations", difficulty: "MEDIUM", summary: "Choose k numbers from 1..n.", minutes: 25 },
      { title: "Permutations", slug: "permutations", difficulty: "MEDIUM", summary: "Used[] or swap-based generation.", minutes: 25 },
      { title: "Combination Sum", slug: "combination-sum", difficulty: "MEDIUM", summary: "Reuse candidates; target remainder.", minutes: 30 },
      { title: "N-Queens II", slug: "n-queens-ii", difficulty: "HARD", summary: "Count solutions with diag constraints.", minutes: 35 },
      { title: "Generate Parentheses", slug: "generate-parentheses", difficulty: "MEDIUM", summary: "Balance open/close counters.", minutes: 25 },
      { title: "Word Search", slug: "word-search", difficulty: "MEDIUM", summary: "Board DFS with visit marks.", minutes: 30 },
    ],
    quizzes: [
      {
        q: "Backtracking differs from plain recursion mainly by:",
        a: "Never returning",
        b: "Undoing choices after exploring a branch",
        c: "Using only BFS",
        d: "Forbidding pruning",
        correct: "B",
        expl: "Apply → explore → revert keeps state consistent.",
        diff: "EASY",
      },
      {
        q: "Combination Sum allows reusing a number by:",
        a: "Passing i+1 always",
        b: "Passing the same index i after choosing candidates[i]",
        c: "Sorting descending only",
        d: "Using a queue",
        correct: "B",
        expl: "Permutations of the same multiset are avoided by nondecreasing index order.",
        diff: "MEDIUM",
      },
      {
        q: "N-Queens column/diag tracking prevents:",
        a: "Duplicate board sizes",
        b: "Attacking placements on the same column or diagonal",
        c: "Odd n",
        d: "Recursion depth > 2",
        correct: "B",
        expl: "Bitsets or boolean arrays mark attacked lines.",
        diff: "MEDIUM",
      },
      {
        q: "Generate Parentheses prunes when:",
        a: "close > open or open > n",
        b: "open == close always",
        c: "n is even",
        d: "The string is empty",
        correct: "A",
        expl: "Never place more closes than opens; never exceed n opens.",
        diff: "MEDIUM",
      },
    ],
  },
  {
    key: "BINARY_SEARCH",
    name: "Binary Search",
    tier: "INTERMEDIATE",
    minutes: 85,
    desc:
      "Search on sorted data and on answer space: classic Binary Search, search rotated array, find peak, median of two sorted arrays, and koko/split array style decisions.",
    theory: `# Binary Search

## On indices
Maintain \`lo..hi\` with a clear predicate: find target, lower_bound, first true.

## On answer space (Top 150 style)
- **Koko Eating Bananas** — binary search speed; feasibility = hours ≤ h.
- **Split Array Largest Sum** — minimize largest partition sum.
- **Median of Two Sorted Arrays** — partition binary search (hard).

## Rotated sorted array
Identify sorted half; decide which half contains target.

## Template tip
Prefer \`while (lo < hi)\` with \`mid = lo + (hi-lo)/2\` and move \`lo = mid+1\` or \`hi = mid\` consistently.`,
    problems: [
      { title: "Search Insert Position", slug: "search-insert-position", difficulty: "EASY", summary: "Lower bound in sorted array.", minutes: 15 },
      { title: "Search a 2D Matrix", slug: "search-a-2d-matrix", difficulty: "MEDIUM", summary: "Treat matrix as virtual sorted array.", minutes: 20 },
      { title: "Find Peak Element", slug: "find-peak-element", difficulty: "MEDIUM", summary: "Binary search on slope.", minutes: 25 },
      { title: "Search in Rotated Sorted Array", slug: "search-in-rotated-sorted-array", difficulty: "MEDIUM", summary: "Identify sorted half each step.", minutes: 30 },
      { title: "Find First and Last Position of Element in Sorted Array", slug: "find-first-and-last-position-of-element-in-sorted-array", difficulty: "MEDIUM", summary: "Two lower/upper bounds.", minutes: 25 },
      { title: "Find Minimum in Rotated Sorted Array", slug: "find-minimum-in-rotated-sorted-array", difficulty: "MEDIUM", summary: "Binary search pivot.", minutes: 25 },
      { title: "Median of Two Sorted Arrays", slug: "median-of-two-sorted-arrays", difficulty: "HARD", summary: "Partition binary search.", minutes: 45 },
    ],
    quizzes: [
      {
        q: "Binary search on answer space requires:",
        a: "A monotonic feasibility predicate",
        b: "The array to be unsorted",
        c: "Graph edges",
        d: "O(1) memory only always",
        correct: "A",
        expl: "If mid is feasible, try smaller (or larger) answers consistently.",
        diff: "MEDIUM",
      },
      {
        q: "In a rotated sorted array with distinct values, one half of [lo,hi] is always:",
        a: "Empty",
        b: "Sorted",
        c: "Bitonic with two peaks",
        d: "All equal",
        correct: "B",
        expl: "Compare nums[lo], nums[mid], nums[hi] to see which side is sorted.",
        diff: "MEDIUM",
      },
      {
        q: "Find Peak Element can binary search because:",
        a: "Any peak works; move toward a greater neighbor",
        b: "The array is strictly increasing",
        c: "n ≤ 2 always",
        d: "Peaks are unique and at index 0",
        correct: "A",
        expl: "Moving uphill guarantees a peak exists in that direction.",
        diff: "MEDIUM",
      },
      {
        q: "Search Insert Position returns:",
        a: "Always 0",
        b: "The lower_bound index where target should be",
        c: "The upper_bound exclusive only for duplicates",
        d: "A random index",
        correct: "B",
        expl: "Classic binary lower bound.",
        diff: "EASY",
      },
    ],
  },
  {
    key: "HEAP",
    name: "Heap / Priority Queue",
    tier: "ADVANCED",
    minutes: 70,
    desc:
      "Top-K and merge patterns: Kth Largest Element, Find Median from Data Stream, Merge k Sorted Lists, IPO, and related Top 150 heap uses.",
    theory: `# Heap / Priority Queue

## When to reach for a heap
- Running **top-k** in a stream.
- Always need current min/max among candidates (**Merge k Sorted Lists**).
- Two-heap median (**Find Median from Data Stream**).

## Complexities
Insert/pop **O(log n)**; building heap **O(n)**.

## Tips
Min-heap of size k for kth largest; keep the larger half in a min-heap and smaller in max-heap for median.`,
    problems: [
      { title: "Kth Largest Element in an Array", slug: "kth-largest-element-in-an-array", difficulty: "MEDIUM", summary: "Min-heap of size k / Quickselect.", minutes: 25 },
      { title: "IPO", slug: "ipo", difficulty: "HARD", summary: "Capital vs profit heaps.", minutes: 40 },
      { title: "Find Median from Data Stream", slug: "find-median-from-data-stream", difficulty: "HARD", summary: "Two heaps balance.", minutes: 40 },
      { title: "Merge k Sorted Lists", slug: "merge-k-sorted-lists", difficulty: "HARD", summary: "Min-heap of list heads.", minutes: 35 },
    ],
    quizzes: [
      {
        q: "Kth largest with a min-heap of size k keeps:",
        a: "All n elements always",
        b: "The k largest seen; heap top is the kth largest",
        c: "Only the maximum",
        d: "Sorted unique values",
        correct: "B",
        expl: "Pop when size > k so top is smallest of the k largest.",
        diff: "MEDIUM",
      },
      {
        q: "Median of a stream with two heaps: max-heap stores:",
        a: "The larger half of numbers",
        b: "The smaller half of numbers",
        c: "Only even indices",
        d: "Graph nodes",
        correct: "B",
        expl: "max-heap for lower half; min-heap for upper half; balance sizes.",
        diff: "HARD",
      },
      {
        q: "Merge k Sorted Lists heap stores:",
        a: "All nodes at once always",
        b: "Current head of each list (up to k nodes)",
        c: "Only the longest list",
        d: "Random samples",
        correct: "B",
        expl: "Pop min, push that list’s next.",
        diff: "MEDIUM",
      },
      {
        q: "Heap insert asymptotic cost is typically:",
        a: "O(1)",
        b: "O(log n)",
        c: "O(n log n)",
        d: "O(n²)",
        correct: "B",
        expl: "Bubble up along tree height.",
        diff: "EASY",
      },
    ],
  },
  {
    key: "GREEDY",
    name: "Greedy",
    tier: "INTERMEDIATE",
    minutes: 65,
    desc:
      "Local optimal choices: Jump Game II, Candy, Gas Station (also arrays), and partition labels style reasoning overlapping Top 150 greedy items.",
    theory: `# Greedy

## Definition
Make the choice that looks best now; prove no better global strategy exists (exchange argument / staying ahead).

## Top 150 anchors
- **Jump Game II** — BFS-like windows of farthest reach per jump count.
- **Candy** — two-pass ratings to satisfy neighbor constraints.
- **Gas Station** — unique start when total ≥ 0; reset tank on negative prefix.

## Red flags
If local choice needs future knowledge that isn’t monotonic, consider DP.`,
    problems: [
      { title: "Jump Game II", slug: "jump-game-ii", difficulty: "MEDIUM", summary: "Minimum jumps via reach windows.", minutes: 30 },
      { title: "Candy", slug: "candy", difficulty: "HARD", summary: "Two-pass rating distribution.", minutes: 35 },
      { title: "Maximum Subarray", slug: "maximum-subarray", difficulty: "MEDIUM", summary: "Kadane’s algorithm (greedy/DP).", minutes: 20 },
      { title: "Maximum Sum Circular Subarray", slug: "maximum-sum-circular-subarray", difficulty: "MEDIUM", summary: "Kadane + total−minSubarray.", minutes: 35 },
    ],
    quizzes: [
      {
        q: "Jump Game II increases jump count when:",
        a: "i exceeds the end of the current reach window",
        b: "nums[i] == 0",
        c: "The array is sorted",
        d: "n is odd",
        correct: "A",
        expl: "Each window is the farthest reachable with the current jump budget.",
        diff: "MEDIUM",
      },
      {
        q: "Kadane’s algorithm tracks:",
        a: "Global max of ending-here sums",
        b: "Only prefix sums",
        c: "Dijkstra distances",
        d: "LIS length only",
        correct: "A",
        expl: "bestEndingHere = max(x, bestEndingHere + x).",
        diff: "EASY",
      },
      {
        q: "Candy two-pass ensures:",
        a: "Random distribution",
        b: "Both left and right neighbor inequalities are satisfied",
        c: "Minimum is always 0",
        d: "Heap order",
        correct: "B",
        expl: "Left-to-right then right-to-left take maxima of requirements.",
        diff: "HARD",
      },
      {
        q: "Circular max subarray combines:",
        a: "Standard Kadane and totalSum − minimum subarray sum",
        b: "Only sorting",
        c: "BFS",
        d: "Trie paths",
        correct: "A",
        expl: "Wrap-around case equals total minus the worst middle segment.",
        diff: "MEDIUM",
      },
    ],
  },
  {
    key: "DP_1D",
    name: "1D Dynamic Programming",
    tier: "ADVANCED",
    minutes: 90,
    desc:
      "Linear DP from Top 150: Climbing Stairs, House Robber, Word Break, Coin Change, Longest Increasing Subsequence.",
    theory: `# 1D Dynamic Programming

## Mindset
Define \`dp[i]\` as an optimal answer for prefix/suffix \`i\`; relate to smaller indices.

## Top 150 catalogue
- **Climbing Stairs** — Fibonacci.
- **House Robber** — take/skip recurrence.
- **Word Break** — boolean DP with dictionary set.
- **Coin Change** — unbounded knapsack for min coins.
- **LIS** — O(n²) DP or O(n log n) tails binary search.

## Space
Many collapse to O(1) or O(W) rolling arrays.`,
    problems: [
      { title: "Climbing Stairs", slug: "climbing-stairs", difficulty: "EASY", summary: "Ways = fibonacci.", minutes: 15 },
      { title: "House Robber", slug: "house-robber", difficulty: "MEDIUM", summary: "Rob or skip adjacent constraint.", minutes: 20 },
      { title: "Word Break", slug: "word-break", difficulty: "MEDIUM", summary: "DP reachability with dict words.", minutes: 30 },
      { title: "Coin Change", slug: "coin-change", difficulty: "MEDIUM", summary: "Min coins unbounded knapsack.", minutes: 30 },
      { title: "Longest Increasing Subsequence", slug: "longest-increasing-subsequence", difficulty: "MEDIUM", summary: "DP or patience sorting tails.", minutes: 35 },
    ],
    quizzes: [
      {
        q: "House Robber recurrence is closest to:",
        a: "dp[i] = max(dp[i-1], dp[i-2] + nums[i])",
        b: "dp[i] = dp[i-1] + dp[i-2]",
        c: "dp[i] = min(nums)",
        d: "dp[i] = nums[i] * i",
        correct: "A",
        expl: "Skip current vs take current + best before previous.",
        diff: "EASY",
      },
      {
        q: "Coin Change (min coins) initializes dp[0] to:",
        a: "Infinity",
        b: "0",
        c: "-1",
        d: "1",
        correct: "B",
        expl: "Zero amount needs zero coins; others start at +∞.",
        diff: "MEDIUM",
      },
      {
        q: "Word Break dp[i] true means:",
        a: "s[0..i) can be segmented into dictionary words",
        b: "s[i] is a vowel",
        c: "i is prime",
        d: "Only one word matches",
        correct: "A",
        expl: "Try breaks j < i where dp[j] and s[j..i) ∈ dict.",
        diff: "MEDIUM",
      },
      {
        q: "LIS O(n log n) maintains:",
        a: "A Fenwick of random keys",
        b: "An array of smallest tails of all increasing subsequences of each length",
        c: "Only the maximum element",
        d: "A BFS queue",
        correct: "B",
        expl: "Binary search replacement in tails array.",
        diff: "HARD",
      },
    ],
  },
  {
    key: "DP_2D",
    name: "Multidimensional DP",
    tier: "ADVANCED",
    minutes: 95,
    desc:
      "Grid and string DP: Unique Paths, Minimum Path Sum, Longest Common Subsequence, Edit Distance, Best Time to Buy and Sell Stock III/IV patterns where present in Top 150.",
    theory: `# Multidimensional DP

## Grid
- **Unique Paths** — dp[i][j] = from top + from left.
- **Minimum Path Sum** — same DAG with costs.
- **Triangle / dungeon** variants — bottom-up often cleaner.

## Strings
- **LCS** — dp[i][j] from prefixes.
- **Edit Distance** — insert/delete/replace transitions.
- **Interleaving String** — 2D boolean reachability.

## Optimization
Rolling arrays when only previous row/column needed.`,
    problems: [
      { title: "Unique Paths II", slug: "unique-paths-ii", difficulty: "MEDIUM", summary: "Grid paths with obstacles.", minutes: 25 },
      { title: "Minimum Path Sum", slug: "minimum-path-sum", difficulty: "MEDIUM", summary: "Min cost path in grid.", minutes: 25 },
      { title: "Longest Common Subsequence", slug: "longest-common-subsequence", difficulty: "MEDIUM", summary: "Classic 2D string DP.", minutes: 30 },
      { title: "Best Time to Buy and Sell Stock III", slug: "best-time-to-buy-and-sell-stock-iii", difficulty: "HARD", summary: "At most two transactions DP.", minutes: 40 },
      { title: "Best Time to Buy and Sell Stock IV", slug: "best-time-to-buy-and-sell-stock-iv", difficulty: "HARD", summary: "At most k transactions.", minutes: 45 },
      { title: "Edit Distance", slug: "edit-distance", difficulty: "MEDIUM", summary: "Levenshtein DP.", minutes: 35 },
    ],
    quizzes: [
      {
        q: "Minimum Path Sum only moves right/down; dp[i][j] equals:",
        a: "grid[i][j] + min(dp[i-1][j], dp[i][j-1]) (edges handled)",
        b: "max of entire grid",
        c: "XOR of path",
        d: "BFS distance only",
        correct: "A",
        expl: "DAG DP on grid.",
        diff: "EASY",
      },
      {
        q: "LCS when characters equal:",
        a: "dp[i][j] = dp[i-1][j-1] + 1",
        b: "dp[i][j] = 0",
        c: "dp[i][j] = i + j",
        d: "Delete both always",
        correct: "A",
        expl: "Else take max of skip either char.",
        diff: "MEDIUM",
      },
      {
        q: "Edit Distance replace transition uses:",
        a: "dp[i-1][j-1] + cost(replace)",
        b: "Only dp[i][j-1]",
        c: "Sorting",
        d: "Heap merge",
        correct: "A",
        expl: "Also consider insert (dp[i][j-1]) and delete (dp[i-1][j]).",
        diff: "MEDIUM",
      },
      {
        q: "Stock DP with at most k transactions models state as:",
        a: "Only current price",
        b: "Day × transaction count × holding/not holding (or compressed)",
        c: "Trie of prices",
        d: "Union-Find of days",
        correct: "B",
        expl: "Classic finite-state machine DP on time.",
        diff: "HARD",
      },
    ],
  },
  {
    key: "BIT_MATH",
    name: "Bit Manipulation & Math",
    tier: "INTERMEDIATE",
    minutes: 60,
    desc:
      "Bit tricks and number theory style Top 150: Single Number, Number of 1 Bits, Reverse Bits, Plus One, Sqrt(x), Pow(x,n), Factorial Trailing Zeroes.",
    theory: `# Bit Manipulation & Math

## Bits
- **Single Number** — XOR all (a⊕a=0).
- **Hamming weight** — \`n &= n-1\` clears lowest set bit.
- **Reverse Bits** — shift build.

## Math
- **Pow(x, n)** — binary exponentiation.
- **Sqrt(x)** — binary search integer root.
- **Trailing Zeroes** — count factors of 5.
- **Plus One** — digit array carry.

## Interview habit
State overflow / negative \`n\` handling for pow.`,
    problems: [
      { title: "Single Number", slug: "single-number", difficulty: "EASY", summary: "XOR accumulation.", minutes: 10 },
      { title: "Number of 1 Bits", slug: "number-of-1-bits", difficulty: "EASY", summary: "Brian Kernighan count.", minutes: 10 },
      { title: "Reverse Bits", slug: "reverse-bits", difficulty: "EASY", summary: "Shift construction.", minutes: 15 },
      { title: "Plus One", slug: "plus-one", difficulty: "EASY", summary: "Digit carry.", minutes: 10 },
      { title: "Sqrt(x)", slug: "sqrtx", difficulty: "EASY", summary: "Binary search integer square root.", minutes: 20 },
      { title: "Pow(x, n)", slug: "powx-n", difficulty: "MEDIUM", summary: "Fast power; handle negative n.", minutes: 25 },
      { title: "Factorial Trailing Zeroes", slug: "factorial-trailing-zeroes", difficulty: "MEDIUM", summary: "Count factors of 5.", minutes: 20 },
    ],
    quizzes: [
      {
        q: "XOR of all elements finds the single number because:",
        a: "x⊕x = 0 and 0⊕y = y",
        b: "XOR sorts the array",
        c: "XOR counts bits in O(n²)",
        d: "XOR needs sorted input",
        correct: "A",
        expl: "Pairs cancel; unique remains.",
        diff: "EASY",
      },
      {
        q: "n & (n-1) is used to:",
        a: "Set the highest bit",
        b: "Clear the lowest set bit",
        c: "Multiply by 2",
        d: "Compute GCD",
        correct: "B",
        expl: "Loop until n==0 for popcount.",
        diff: "EASY",
      },
      {
        q: "Trailing zeroes in n! equal:",
        a: "n/2",
        b: "Number of times 5 divides numbers ≤ n (including 25, 125, …)",
        c: "Number of even factors only",
        d: "log2(n)",
        correct: "B",
        expl: "Each 5 pairs with a 2 to make a trailing zero.",
        diff: "MEDIUM",
      },
      {
        q: "Binary exponentiation computes pow by:",
        a: "Multiplying x, n times always",
        b: "Squaring and consuming bits of the exponent",
        c: "DFS on digits",
        d: "Heap of powers",
        correct: "B",
        expl: "O(log |n|) multiplications.",
        diff: "MEDIUM",
      },
    ],
  },
  {
    key: "UNION_FIND",
    name: "Union Find",
    tier: "ADVANCED",
    minutes: 50,
    desc:
      "Disjoint sets for connectivity-style Top 150 items such as Number of Provinces and graph connectivity variants.",
    theory: `# Union-Find (DSU)

## API
- \`find(x)\` with path compression.
- \`union(a,b)\` with union by rank/size.

## Top 150 fit
- **Number of Provinces** — union connected cities; count roots.
- Connectivity queries / redundant connection style problems.

## Complexity
Almost O(1) per op with both optimizations (inverse Ackermann).`,
    problems: [
      { title: "Number of Provinces", slug: "number-of-provinces", difficulty: "MEDIUM", summary: "DSU or DFS components on matrix.", minutes: 25 },
    ],
    quizzes: [
      {
        q: "Path compression in find():",
        a: "Deletes all nodes",
        b: "Points nodes directly toward the root along the lookup path",
        c: "Sorts children",
        d: "Builds a segment tree",
        correct: "B",
        expl: "Flattens trees for faster future finds.",
        diff: "MEDIUM",
      },
      {
        q: "Union by rank prefers attaching:",
        a: "Larger rank tree under smaller",
        b: "Smaller rank tree under larger rank root",
        c: "Random trees only",
        d: "Only leaves",
        correct: "B",
        expl: "Keeps tree shallow.",
        diff: "EASY",
      },
      {
        q: "Number of Provinces with DSU equals:",
        a: "n always",
        b: "Count of distinct roots after processing edges/adjacency",
        c: "Number of 0s in the matrix",
        d: "Graph diameter",
        correct: "B",
        expl: "Each remaining component has one representative.",
        diff: "EASY",
      },
      {
        q: "DSU is a poor fit when you need:",
        a: "Dynamic connectivity of undirected edges",
        b: "Shortest path distances",
        c: "Component counting",
        d: "Cycle detection in undirected add-edge streams (sometimes OK)",
        correct: "B",
        expl: "Use BFS/Dijkstra for distances; DSU tracks membership.",
        diff: "MEDIUM",
      },
    ],
  },
];

function buildSql() {
  const lines = [];
  const push = (s = "") => lines.push(s);

  push(`USE [LEARNING_SERVICE];`);
  push(`GO`);
  push(`SET NOCOUNT ON;`);
  push(`SET XACT_ABORT ON;`);
  push(`GO`);
  push(`/*`);
  push(`================================================================================`);
  push(`  PRODUCTION SEED — DSA Learning Path (LeetCode Top Interview 150 aligned)`);
  push(`================================================================================`);
  push(`  PATHKEY: DSA_TOP150`);
  push(``);
  push(`  Inserts / upserts:`);
  push(`    - LEARNING_PATH_MASTER`);
  push(`    - TOPIC_MASTER (theory markdown + prerequisites)`);
  push(`    - CONTENT_ITEM (LeetCode PROBLEM links)`);
  push(`    - QUIZ_QUESTION_MASTER (concept quizzes per topic)`);
  push(``);
  push(`  Safe to re-run: upserts path/topics; refreshes content + quizzes for this path`);
  push(`  only when those rows are not referenced by LEARNING_QUIZ_ATTEMPT / daily plans`);
  push(`  in a blocking way — content/quiz rows for this path are replaced carefully.`);
  push(``);
  push(`  Prerequisites: tables.sql applied on LEARNING_SERVICE.`);
  push(`================================================================================`);
  push(`*/`);
  push(`BEGIN TRANSACTION;`);
  push(``);
  push(`DECLARE @PATHKEY NVARCHAR(50) = N'DSA_TOP150';`);
  push(`DECLARE @PATHID INT;`);
  push(`DECLARE @PATH_ORDER INT;`);
  push(``);
  push(`IF NOT EXISTS (SELECT 1 FROM dbo.LEARNING_PATH_MASTER WHERE PATHKEY = @PATHKEY)`);
  push(`BEGIN`);
  push(`    SELECT @PATH_ORDER = ISNULL(MAX(DISPLAYORDER), 0) + 1 FROM dbo.LEARNING_PATH_MASTER;`);
  push(`    INSERT INTO dbo.LEARNING_PATH_MASTER`);
  push(`        (PATHKEY, PATHNAME, DESCRIPTION, PATHEMOJI, DISPLAYORDER, ISACTIVE)`);
  push(`    VALUES`);
  push(`        (@PATHKEY,`);
  push(`         N'DSA — LeetCode Top Interview 150',`);
  push(`         N'Interview-oriented Data Structures & Algorithms curriculum aligned to the LeetCode Top Interview 150 study plan: arrays, two pointers, sliding window, hash maps, intervals, stacks, linked lists, trees, graphs, tries, backtracking, binary search, heaps, greedy, DP, bits/math, and union-find.',`);
  push(`         N'🧩',`);
  push(`         @PATH_ORDER,`);
  push(`         1);`);
  push(`END`);
  push(`ELSE`);
  push(`BEGIN`);
  push(`    UPDATE dbo.LEARNING_PATH_MASTER`);
  push(`    SET PATHNAME = N'DSA — LeetCode Top Interview 150',`);
  push(`        DESCRIPTION = N'Interview-oriented Data Structures & Algorithms curriculum aligned to the LeetCode Top Interview 150 study plan: arrays, two pointers, sliding window, hash maps, intervals, stacks, linked lists, trees, graphs, tries, backtracking, binary search, heaps, greedy, DP, bits/math, and union-find.',`);
  push(`        PATHEMOJI = N'🧩',`);
  push(`        ISACTIVE = 1,`);
  push(`        UPDATEDDATE = SYSUTCDATETIME()`);
  push(`    WHERE PATHKEY = @PATHKEY;`);
  push(`END`);
  push(``);
  push(`SELECT @PATHID = PATHID FROM dbo.LEARNING_PATH_MASTER WHERE PATHKEY = @PATHKEY;`);
  push(``);
  topics.forEach((t) => {
    push(`DECLARE @T_${t.key} INT;`);
  });
  push(``);
  push(`/* Refresh quizzes/content for this path when not referenced by attempts */`);
  push(`DELETE QQ`);
  push(`FROM dbo.QUIZ_QUESTION_MASTER QQ`);
  push(`INNER JOIN dbo.TOPIC_MASTER T ON T.TOPICID = QQ.TOPICID`);
  push(`WHERE T.PATHID = @PATHID`);
  push(`  AND NOT EXISTS (SELECT 1 FROM dbo.LEARNING_QUIZ_ATTEMPT A WHERE A.QUESTIONID = QQ.QUESTIONID);`);
  push(``);
  push(`DELETE CI`);
  push(`FROM dbo.CONTENT_ITEM CI`);
  push(`INNER JOIN dbo.TOPIC_MASTER T ON T.TOPICID = CI.TOPICID`);
  push(`WHERE T.PATHID = @PATHID`);
  push(`  AND NOT EXISTS (SELECT 1 FROM dbo.DAILY_LEARNING_PLAN P WHERE P.CONTENTID = CI.CONTENTID)`);
  push(`  AND NOT EXISTS (SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER QQ WHERE QQ.CONTENTID = CI.CONTENTID);`);
  push(``);

  topics.forEach((t, idx) => {
    const order = idx + 1;
    const prevKey = idx === 0 ? null : topics[idx - 1].key;
    push(`/* ---- Topic ${order}: ${t.name} ---- */`);
    push(`IF NOT EXISTS (SELECT 1 FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = ${n(t.key)})`);
    push(`BEGIN`);
    push(`    INSERT INTO dbo.TOPIC_MASTER`);
    push(`        (PATHID, TOPICKEY, TOPICNAME, DESCRIPTION, DIFFICULTYTIER, DISPLAYORDER,`);
    push(`         PREREQUISITETOPICID, ESTIMATEDMINUTES, THEORYMARKDOWN, ISACTIVE)`);
    push(`    VALUES`);
    push(`        (@PATHID, ${n(t.key)}, ${n(t.name)}, ${n(t.desc)}, ${n(t.tier)}, ${order},`);
    if (prevKey) {
      push(`         (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = ${n(prevKey)}),`);
    } else {
      push(`         NULL,`);
    }
    push(`         ${t.minutes}, ${n(t.theory)}, 1);`);
    push(`END`);
    push(`ELSE`);
    push(`BEGIN`);
    push(`    UPDATE dbo.TOPIC_MASTER`);
    push(`    SET TOPICNAME = ${n(t.name)},`);
    push(`        DESCRIPTION = ${n(t.desc)},`);
    push(`        DIFFICULTYTIER = ${n(t.tier)},`);
    push(`        DISPLAYORDER = ${order},`);
    if (prevKey) {
      push(`        PREREQUISITETOPICID = (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = ${n(prevKey)}),`);
    } else {
      push(`        PREREQUISITETOPICID = NULL,`);
    }
    push(`        ESTIMATEDMINUTES = ${t.minutes},`);
    push(`        THEORYMARKDOWN = ${n(t.theory)},`);
    push(`        ISACTIVE = 1,`);
    push(`        UPDATEDDATE = SYSUTCDATETIME()`);
    push(`    WHERE PATHID = @PATHID AND TOPICKEY = ${n(t.key)};`);
    push(`END`);
    push(`SELECT @T_${t.key} = TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = ${n(t.key)};`);
    push(``);

    t.problems.forEach((p, pi) => {
      const url = `https://leetcode.com/problems/${p.slug}/`;
      push(`IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_${t.key} AND EXTERNALURL = ${n(url)})`);
      push(`BEGIN`);
      push(`    INSERT INTO dbo.CONTENT_ITEM`);
      push(`        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)`);
      push(`    VALUES`);
      push(`        (@T_${t.key}, N'PROBLEM', ${n(p.title)}, ${n(p.summary)}, ${n(url)}, N'LEETCODE', ${n(p.difficulty)}, ${pi + 1}, ${p.minutes}, 1);`);
      push(`END`);
      push(`ELSE`);
      push(`BEGIN`);
      push(`    UPDATE dbo.CONTENT_ITEM`);
      push(`    SET TITLE = ${n(p.title)}, SUMMARY = ${n(p.summary)}, PLATFORMCODE = N'LEETCODE',`);
      push(`        DIFFICULTY = ${n(p.difficulty)}, DISPLAYORDER = ${pi + 1}, ESTIMATEDMINUTES = ${p.minutes},`);
      push(`        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()`);
      push(`    WHERE TOPICID = @T_${t.key} AND EXTERNALURL = ${n(url)};`);
      push(`END`);
      push(``);
    });

    // Theory content item
    push(`IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_${t.key} AND CONTENTTYPE = N'THEORY' AND TITLE = ${n(t.name + " — Theory")})`);
    push(`BEGIN`);
    push(`    INSERT INTO dbo.CONTENT_ITEM`);
    push(`        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)`);
    push(`    VALUES`);
    push(`        (@T_${t.key}, N'THEORY', ${n(t.name + " — Theory")}, ${n("Interview-oriented theory for " + t.name + " (Top 150 patterns).")}, NULL, N'STREAKLY', N'MEDIUM', 0, 20, 1);`);
    push(`END`);
    push(``);

    t.quizzes.forEach((qz, qi) => {
      push(`IF NOT EXISTS (`);
      push(`    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER`);
      push(`    WHERE TOPICID = @T_${t.key} AND DISPLAYORDER = ${qi + 1} AND QUESTIONTEXT = ${n(qz.q)}`);
      push(`)`);
      push(`AND NOT EXISTS (`);
      push(`    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER`);
      push(`    WHERE TOPICID = @T_${t.key} AND QUESTIONTEXT = ${n(qz.q)}`);
      push(`)`);
      push(`BEGIN`);
      push(`    INSERT INTO dbo.QUIZ_QUESTION_MASTER`);
      push(`        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,`);
      push(`         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)`);
      push(`    VALUES`);
      push(`        (@T_${t.key}, NULL, ${n(qz.q)}, ${n(qz.a)}, ${n(qz.b)}, ${n(qz.c)}, ${n(qz.d)},`);
      push(`         ${n(qz.correct)}, ${n(qz.expl)}, ${n(qz.diff)}, ${qi + 1}, 1);`);
      push(`END`);
      push(`ELSE`);
      push(`BEGIN`);
      push(`    UPDATE dbo.QUIZ_QUESTION_MASTER`);
      push(`    SET OPTIONA = ${n(qz.a)}, OPTIONB = ${n(qz.b)}, OPTIONC = ${n(qz.c)}, OPTIOND = ${n(qz.d)},`);
      push(`        CORRECTOPTION = ${n(qz.correct)}, EXPLANATION = ${n(qz.expl)}, DIFFICULTY = ${n(qz.diff)},`);
      push(`        DISPLAYORDER = ${qi + 1}, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()`);
      push(`    WHERE TOPICID = @T_${t.key} AND QUESTIONTEXT = ${n(qz.q)};`);
      push(`END`);
      push(``);
    });
  });

  push(`/* Verification */`);
  push(`SELECT 'PATH' AS KIND, PATHID, PATHKEY, PATHNAME FROM dbo.LEARNING_PATH_MASTER WHERE PATHID = @PATHID;`);
  push(`SELECT COUNT(*) AS TOPIC_COUNT FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID;`);
  push(`SELECT COUNT(*) AS CONTENT_COUNT`);
  push(`FROM dbo.CONTENT_ITEM CI`);
  push(`INNER JOIN dbo.TOPIC_MASTER T ON T.TOPICID = CI.TOPICID`);
  push(`WHERE T.PATHID = @PATHID;`);
  push(`SELECT COUNT(*) AS QUIZ_COUNT`);
  push(`FROM dbo.QUIZ_QUESTION_MASTER QQ`);
  push(`INNER JOIN dbo.TOPIC_MASTER T ON T.TOPICID = QQ.TOPICID`);
  push(`WHERE T.PATHID = @PATHID;`);
  push(`SELECT T.TOPICKEY, T.TOPICNAME,`);
  push(`       (SELECT COUNT(*) FROM dbo.CONTENT_ITEM C WHERE C.TOPICID = T.TOPICID AND C.ISACTIVE = 1) AS CONTENTS,`);
  push(`       (SELECT COUNT(*) FROM dbo.QUIZ_QUESTION_MASTER Q WHERE Q.TOPICID = T.TOPICID AND Q.ISACTIVE = 1) AS QUESTIONS`);
  push(`FROM dbo.TOPIC_MASTER T`);
  push(`WHERE T.PATHID = @PATHID`);
  push(`ORDER BY T.DISPLAYORDER;`);
  push(``);
  push(`COMMIT TRANSACTION;`);
  push(`GO`);
  push(`PRINT 'DSA_TOP150 seed completed successfully.';`);
  push(`GO`);

  return lines.join("\n");
}

const out = path.join(__dirname, "10_SEED_DSA_LEETCODE_TOP150.sql");
fs.writeFileSync(out, buildSql(), "utf8");
console.log("Wrote", out);
console.log("Topics:", topics.length);
console.log(
  "Problems:",
  topics.reduce((s, t) => s + t.problems.length, 0),
);
console.log(
  "Quizzes:",
  topics.reduce((s, t) => s + t.quizzes.length, 0),
);
