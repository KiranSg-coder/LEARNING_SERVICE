USE [LEARNING_SERVICE];
GO

/*
  Additional seed data for PATHID 1 (DSA) and PATHID 2 (System Design).
  Assumes you already ran inserts for:
    PATHID 1–2, TOPICID 1–2, CONTENTID 1–2, QUESTIONID 1–3, USER 1001 profile + enrollment on path 1 only.

  This script does NOT re-insert paths, topics 1–2, content 1–2, questions 1–3, or USER_LEARNING_PROFILE.
*/

-- ── Sliding Window (TOPIC 2): add quiz rows (none in original seed) ─────────
SET IDENTITY_INSERT [dbo].[QUIZ_QUESTION_MASTER] ON;
INSERT INTO [dbo].[QUIZ_QUESTION_MASTER]
    ([QUESTIONID], [TOPICID], [CONTENTID], [QUESTIONTEXT], [OPTIONA], [OPTIONB], [OPTIONC], [OPTIOND],
     [CORRECTOPTION], [EXPLANATION], [DIFFICULTY], [DISPLAYORDER], [ISACTIVE])
VALUES
    (4, 2, NULL, N'Fixed-size sliding window: to move the window one step, what updates in O(1)?',
     N'Add incoming element, remove outgoing element from window aggregate', N'Sort the whole array each time', N'Rebuild window from scratch', N'Use only brute force',
     N'A', N'Slide by updating counts/sum for edges only.', N'MEDIUM', 1, 1),
    (5, 2, NULL, N'When is sliding window preferred over checking every substring naively?',
     N'When you need contiguous subarray/substring constraints in linear time', N'Never', N'Only for sorted arrays', N'Only for trees',
     N'A', N'Window amortizes work across the string/array.', N'EASY', 2, 1);
SET IDENTITY_INSERT [dbo].[QUIZ_QUESTION_MASTER] OFF;
GO

-- ── More DSA topics (PATHID 1) ─────────────────────────────────────────────
SET IDENTITY_INSERT [dbo].[TOPIC_MASTER] ON;
INSERT INTO [dbo].[TOPIC_MASTER]
    ([TOPICID], [PATHID], [TOPICKEY], [TOPICNAME], [DESCRIPTION], [DIFFICULTYTIER], [DISPLAYORDER],
     [PREREQUISITETOPICID], [ESTIMATEDMINUTES], [THEORYMARKDOWN], [ISACTIVE])
VALUES
    (3, 1, N'STACKS_QUEUES', N'Stacks & Queues', N'LIFO/FIFO patterns, monotonic stack intro', N'INTERMEDIATE', 3, 2, 50,
     N'# Stacks & Queues\n- **Stack**: DFS, parentheses, monotonic stack for next-greater.\n- **Queue**: BFS, sliding window deque variant.', 1),
    (4, 1, N'BINARY_SEARCH', N'Binary Search', N'On sorted data and answer-space search', N'INTERMEDIATE', 4, 3, 55,
     N'# Binary Search\nSearch sorted array in O(log n). On answers: minimize/maximize feasible value.', 1),
    (5, 1, N'LINKED_LIST', N'Linked Lists', N'Pointers, cycles, merge lists', N'BEGINNER', 5, 1, 40,
     N'# Linked Lists\nDummy head simplifies inserts; fast/slow pointers for cycles.', 1),
    (6, 1, N'TREES_BST', N'Trees & BST', N'Traversals, height, validation', N'INTERMEDIATE', 6, 5, 70, NULL, 1),
    (7, 1, N'GRAPHS_BFS_DFS', N'Graphs: BFS & DFS', N'Adjacency list, components, shortest path unweighted', N'ADVANCED', 7, 6, 75,
     N'# Graphs\nBFS for unweighted shortest path; DFS for connectivity and cycles.', 1);
SET IDENTITY_INSERT [dbo].[TOPIC_MASTER] OFF;
GO

-- ── System Design topics (PATHID 2) ────────────────────────────────────────
SET IDENTITY_INSERT [dbo].[TOPIC_MASTER] ON;
INSERT INTO [dbo].[TOPIC_MASTER]
    ([TOPICID], [PATHID], [TOPICKEY], [TOPICNAME], [DESCRIPTION], [DIFFICULTYTIER], [DISPLAYORDER],
     [PREREQUISITETOPICID], [ESTIMATEDMINUTES], [THEORYMARKDOWN], [ISACTIVE])
VALUES
    (8, 2, N'SD_SCALING_BASICS', N'Scaling basics', N'Horizontal vs vertical, stateless apps', N'BEGINNER', 1, NULL, 40,
     N'# Scaling\n- **Vertical**: bigger machine.\n- **Horizontal**: more nodes + load balancing.\n- Keep **state** in DB/cache, not on one app node.', 1),
    (9, 2, N'SD_LOAD_BALANCING', N'Load balancing', N'L4/L7, health checks, session stickiness', N'INTERMEDIATE', 2, 8, 45,
     N'# Load balancing\nDistribute traffic; health checks remove bad nodes; sticky sessions when needed.', 1),
    (10, 2, N'SD_CACHING', N'Caching', N'CDN, Redis, cache-aside, TTL, eviction', N'INTERMEDIATE', 3, 9, 50,
     N'# Caching\nReduce read load; watch **staleness** and **thundering herd**; TTL + invalidation strategy.', 1),
    (11, 2, N'SD_DATABASES', N'Databases & replication', N'RDBMS, read replicas, sharding intro', N'INTERMEDIATE', 4, 10, 55, NULL, 1),
    (12, 2, N'SD_MESSAGING', N'Message queues', N'Async work, backpressure, idempotency', N'ADVANCED', 5, 11, 50,
     N'# Messaging\nDecouple producers/consumers; retries + **idempotent** consumers.', 1);
SET IDENTITY_INSERT [dbo].[TOPIC_MASTER] OFF;
GO

-- ── Content items (new TOPICIDs only) ─────────────────────────────────────
SET IDENTITY_INSERT [dbo].[CONTENT_ITEM] ON;
INSERT INTO [dbo].[CONTENT_ITEM]
    ([CONTENTID], [TOPICID], [CONTENTTYPE], [TITLE], [SUMMARY], [EXTERNALURL], [PLATFORMCODE], [DIFFICULTY], [DISPLAYORDER], [ESTIMATEDMINUTES], [ISACTIVE])
VALUES
    -- DSA: Stacks & Queues (3)
    (3, 3, N'PROBLEM', N'Valid Parentheses', N'Stack classic', N'https://leetcode.com/problems/valid-parentheses/', N'LEETCODE', N'EASY', 1, 25, 1),
    (4, 3, N'PROBLEM', N'Daily Temperatures', N'Monotonic stack', N'https://leetcode.com/problems/daily-temperatures/', N'LEETCODE', N'MEDIUM', 2, 35, 1),
    -- DSA: Binary Search (4)
    (5, 4, N'PROBLEM', N'Binary Search', N'Template practice', N'https://leetcode.com/problems/binary-search/', N'LEETCODE', N'EASY', 1, 20, 1),
    (6, 4, N'PROBLEM', N'Search in Rotated Sorted Array', N'Two-pass binary search idea', N'https://leetcode.com/problems/search-in-rotated-sorted-array/', N'LEETCODE', N'MEDIUM', 2, 40, 1),
    -- DSA: Linked Lists (5)
    (7, 5, N'PROBLEM', N'Reverse Linked List', N'Iterative / recursive', N'https://leetcode.com/problems/reverse-linked-list/', N'LEETCODE', N'EASY', 1, 25, 1),
    (8, 5, N'PROBLEM', N'Merge Two Sorted Lists', N'Dummy node pattern', N'https://leetcode.com/problems/merge-two-sorted-lists/', N'LEETCODE', N'EASY', 2, 25, 1),
    -- DSA: Trees (6)
    (9, 6, N'PROBLEM', N'Maximum Depth of Binary Tree', N'BFS/DFS', N'https://leetcode.com/problems/maximum-depth-of-binary-tree/', N'LEETCODE', N'EASY', 1, 20, 1),
    (10, 6, N'PROBLEM', N'Validate Binary Search Tree', N'Bounds trick', N'https://leetcode.com/problems/validate-binary-search-tree/', N'LEETCODE', N'MEDIUM', 2, 35, 1),
    -- DSA: Graphs (7)
    (11, 7, N'PROBLEM', N'Number of Islands', N'Grid DFS/BFS', N'https://leetcode.com/problems/number-of-islands/', N'LEETCODE', N'MEDIUM', 1, 40, 1),
    (12, 7, N'ARTICLE', N'Graph algorithms overview', N'Visual intro', N'https://www.youtube.com/watch?v=tWVWeAqZ0WU', N'YOUTUBE', NULL, 2, 25, 1),
    -- System Design (8–12)
    (13, 8, N'ARTICLE', N'Scalability lecture (MIT)', N'High-level scaling', N'https://www.youtube.com/watch?v=-W0Fvnh1LK4', N'YOUTUBE', NULL, 1, 35, 1),
    (14, 9, N'ARTICLE', N'Load balancing explained', N'NGINX / cloud LB concepts', N'https://www.nginx.com/resources/glossary/load-balancing/', N'WEB', NULL, 1, 25, 1),
    (15, 9, N'ARTICLE', N'AWS Elastic Load Balancing', N'Official overview', N'https://aws.amazon.com/elasticloadbalancing/', N'WEB', NULL, 2, 25, 1),
    (16, 10, N'ARTICLE', N'Caching strategies', N'Cache-aside, write-through', N'https://learn.microsoft.com/en-us/azure/architecture/patterns/cache-aside', N'WEB', NULL, 1, 30, 1),
    (17, 10, N'ARTICLE', N'Redis documentation', N'Data structures + TTL', N'https://redis.io/docs/', N'WEB', NULL, 2, 25, 1),
    (18, 11, N'ARTICLE', N'Database replication', N'Read replicas basics', N'https://www.postgresql.org/docs/current/high-availability.html', N'WEB', NULL, 1, 30, 1),
    (19, 11, N'ARTICLE', N'Sharding introduction', N'Horizontal partitioning', N'https://www.mongodb.com/basics/sharding', N'WEB', NULL, 2, 30, 1),
    (20, 12, N'ARTICLE', N'RabbitMQ tutorials', N'Queues & workers', N'https://www.rabbitmq.com/getstarted.html', N'WEB', NULL, 1, 35, 1),
    (21, 12, N'ARTICLE', N'AWS SQS overview', N'Managed queues', N'https://aws.amazon.com/sqs/', N'WEB', NULL, 2, 25, 1);
SET IDENTITY_INSERT [dbo].[CONTENT_ITEM] OFF;
GO

-- ── Quiz questions (≥2 per topic for plan generator) ───────────────────────
SET IDENTITY_INSERT [dbo].[QUIZ_QUESTION_MASTER] ON;
INSERT INTO [dbo].[QUIZ_QUESTION_MASTER]
    ([QUESTIONID], [TOPICID], [CONTENTID], [QUESTIONTEXT], [OPTIONA], [OPTIONB], [OPTIONC], [OPTIOND],
     [CORRECTOPTION], [EXPLANATION], [DIFFICULTY], [DISPLAYORDER], [ISACTIVE])
VALUES
    -- Topic 3: Stacks & Queues
    (6, 3, NULL, N'Which DS is naturally used to check balanced parentheses?',
     N'Stack', N'Queue', N'Priority queue', N'Hash map only', N'A', N'Push opens, pop matches closes.', N'EASY', 1, 1),
    (7, 3, NULL, N'BFS on a graph typically uses which structure?',
     N'Queue', N'Stack', N'Heap', N'Union-find', N'A', N'FIFO explores level by level.', N'EASY', 2, 1),
    -- Topic 4: Binary Search
    (8, 4, NULL, N'Binary search on a sorted array of n elements takes roughly:',
     N'O(log n)', N'O(n)', N'O(n log n)', N'O(1)', N'A', N'Halve search space each step.', N'EASY', 1, 1),
    (9, 4, NULL, N'When searching for first/last position of target, you often adjust mid to:',
     N'Shrink toward the boundary you want', N'Always pick mid = (lo+hi)/2 without branches', N'Sort descending', N'Skip half randomly',
     N'A', N'Classic lower/upper bound templates.', N'MEDIUM', 2, 1),
    -- Topic 5: Linked Lists
    (10, 5, NULL, N'Cycle detection in a linked list often uses:',
     N'Two pointers (fast/slow)', N'Only one pointer', N'Sorting the list', N'Hash map only (never two pointers)', N'A', N'Floyd’s tortoise and hare.', N'MEDIUM', 1, 1),
    (11, 5, NULL, N'Dummy head node mainly helps with:',
     N'Edge cases at list head', N'Reducing space to O(1) always', N'Avoiding null checks entirely forever', N'Parallel CPU work', N'A', N'Simplifies insert/delete at front.', N'EASY', 2, 1),
    -- Topic 6: Trees
    (12, 6, NULL, N'In-order traversal of a BST visits nodes in:',
     N'Sorted order (for numeric keys)', N'Random order', N'Reverse sorted only', N'Level order always', N'A', N'Left → root → right.', N'EASY', 1, 1),
    (13, 6, NULL, N'To validate a BST, each node must obey bounds from:',
     N'All ancestors on the path', N'Only its parent', N'Only the root value', N'Leaf count', N'A', N'Pass min/max down the recursion.', N'MEDIUM', 2, 1),
    -- Topic 7: Graphs
    (14, 7, NULL, N'Unweighted shortest path in an unweighted graph:',
     N'BFS', N'DFS only', N'Dijkstra always required', N'Topological sort only', N'A', N'BFS expands by hop count.', N'EASY', 1, 1),
    (15, 7, NULL, N'For a 2D grid “islands” problem, each land cell often triggers:',
     N'DFS/BFS flood fill marking visited', N'Sorting rows', N'Binary search on grid', N'Single pass without visited', N'A', N'Visit connected 1s.', N'MEDIUM', 2, 1),
    -- Topic 8: Scaling basics
    (16, 8, NULL, N'Stateless application servers help scaling because:',
     N'Any instance can handle a request; session stored externally', N'They never use databases', N'They remove need for load balancers', N'They guarantee strong consistency', N'A', N'Session/cache/DB hold shared state.', N'EASY', 1, 1),
    (17, 8, NULL, N'Horizontal scaling means:',
     N'Add more machines/nodes', N'Only buy a bigger CPU on one box', N'Disable caching', N'Single-thread the app', N'A', N'Scale out.', N'EASY', 2, 1),
    -- Topic 9: Load balancing
    (18, 9, NULL, N'Layer-7 load balancing routes using:',
     N'HTTP headers, path, host', N'Only IP and port', N'Disk sector', N'CPU temperature', N'A', N'Application-aware routing.', N'MEDIUM', 1, 1),
    (19, 9, NULL, N'Health checks on load balancers primarily:',
     N'Remove failed backends from rotation', N'Encrypt all traffic', N'Replace DNS', N'Store user passwords', N'A', N'Probe /health or TCP.', N'EASY', 2, 1),
    -- Topic 10: Caching
    (20, 10, NULL, N'Cache-aside pattern: on miss, the app usually:',
     N'Loads from DB, then populates cache', N'Always writes cache first only', N'Skips DB forever', N'Deletes all keys', N'A', N'Read-through variant similar.', N'MEDIUM', 1, 1),
    (21, 10, NULL, N'TTL in a cache primarily limits:',
     N'How long stale data may live', N'Number of CPU cores', N'Database primary keys', N'HTTP status codes', N'A', N'Time-based expiry.', N'EASY', 2, 1),
    -- Topic 11: Databases
    (22, 11, NULL, N'Read replicas mainly improve:',
     N'Read scalability and latency for reads', N'Write throughput unlimited', N'Strong consistency on all reads instantly', N'Client-side encryption', N'A', N'Async replication caveat.', N'MEDIUM', 1, 1),
    (23, 11, NULL, N'Sharding splits data by:',
     N'Shard key / partition strategy', N'Random file rename', N'Single global sort', N'Client browser only', N'A', N'Horizontal partition.', N'EASY', 2, 1),
    -- Topic 12: Messaging
    (24, 12, NULL, N'A queue between services mainly provides:',
     N'Asynchronous decoupling and buffering', N'Synchronous locks only', N'Guaranteed zero duplicates always', N'In-memory graph storage', N'A', N'Consumers pull at their pace.', N'EASY', 1, 1),
    (25, 12, NULL, N'Idempotent consumers help when:',
     N'Messages may be delivered more than once', N'Never in real systems', N'Only for JSON', N'Only without retries', N'A', N'At-least-once delivery.', N'MEDIUM', 2, 1);
SET IDENTITY_INSERT [dbo].[QUIZ_QUESTION_MASTER] OFF;
GO

-- Optional: enroll test user on System Design path (priority 2)
IF NOT EXISTS (SELECT 1 FROM [dbo].[USER_PATH_ENROLLMENT] WHERE [USERID] = 1001 AND [PATHID] = 2)
INSERT INTO [dbo].[USER_PATH_ENROLLMENT] ([USERID], [PATHID], [ISACTIVE], [PRIORITYORDER])
VALUES (1001, 2, 1, 2);
GO
