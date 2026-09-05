USE [LEARNING_SERVICE];
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO
/*
================================================================================
  PRODUCTION SEED — DSA Learning Path (LeetCode Top Interview 150 aligned)
================================================================================
  PATHKEY: DSA_TOP150

  Inserts / upserts:
    - LEARNING_PATH_MASTER
    - TOPIC_MASTER (theory markdown + prerequisites)
    - CONTENT_ITEM (LeetCode PROBLEM links)
    - QUIZ_QUESTION_MASTER (concept quizzes per topic)

  Safe to re-run: upserts path/topics; refreshes content + quizzes for this path
  only when those rows are not referenced by LEARNING_QUIZ_ATTEMPT / daily plans
  in a blocking way — content/quiz rows for this path are replaced carefully.

  Prerequisites: tables.sql applied on LEARNING_SERVICE.
================================================================================
*/
BEGIN TRANSACTION;

DECLARE @PATHKEY NVARCHAR(50) = N'DSA_TOP150';
DECLARE @PATHID INT;
DECLARE @PATH_ORDER INT;

IF NOT EXISTS (SELECT 1 FROM dbo.LEARNING_PATH_MASTER WHERE PATHKEY = @PATHKEY)
BEGIN
    SELECT @PATH_ORDER = ISNULL(MAX(DISPLAYORDER), 0) + 1 FROM dbo.LEARNING_PATH_MASTER;
    INSERT INTO dbo.LEARNING_PATH_MASTER
        (PATHKEY, PATHNAME, DESCRIPTION, PATHEMOJI, DISPLAYORDER, ISACTIVE)
    VALUES
        (@PATHKEY,
         N'DSA — LeetCode Top Interview 150',
         N'Interview-oriented Data Structures & Algorithms curriculum aligned to the LeetCode Top Interview 150 study plan: arrays, two pointers, sliding window, hash maps, intervals, stacks, linked lists, trees, graphs, tries, backtracking, binary search, heaps, greedy, DP, bits/math, and union-find.',
         N'🧩',
         @PATH_ORDER,
         1);
END
ELSE
BEGIN
    UPDATE dbo.LEARNING_PATH_MASTER
    SET PATHNAME = N'DSA — LeetCode Top Interview 150',
        DESCRIPTION = N'Interview-oriented Data Structures & Algorithms curriculum aligned to the LeetCode Top Interview 150 study plan: arrays, two pointers, sliding window, hash maps, intervals, stacks, linked lists, trees, graphs, tries, backtracking, binary search, heaps, greedy, DP, bits/math, and union-find.',
        PATHEMOJI = N'🧩',
        ISACTIVE = 1,
        UPDATEDDATE = SYSUTCDATETIME()
    WHERE PATHKEY = @PATHKEY;
END

SELECT @PATHID = PATHID FROM dbo.LEARNING_PATH_MASTER WHERE PATHKEY = @PATHKEY;

DECLARE @T_ARRAYS_STRINGS INT;
DECLARE @T_TWO_POINTERS INT;
DECLARE @T_SLIDING_WINDOW INT;
DECLARE @T_HASH_MAP INT;
DECLARE @T_INTERVALS INT;
DECLARE @T_STACK INT;
DECLARE @T_LINKED_LIST INT;
DECLARE @T_BINARY_TREE INT;
DECLARE @T_GRAPH INT;
DECLARE @T_TRIE INT;
DECLARE @T_BACKTRACKING INT;
DECLARE @T_BINARY_SEARCH INT;
DECLARE @T_HEAP INT;
DECLARE @T_GREEDY INT;
DECLARE @T_DP_1D INT;
DECLARE @T_DP_2D INT;
DECLARE @T_BIT_MATH INT;
DECLARE @T_UNION_FIND INT;

/* Refresh quizzes/content for this path when not referenced by attempts */
DELETE QQ
FROM dbo.QUIZ_QUESTION_MASTER QQ
INNER JOIN dbo.TOPIC_MASTER T ON T.TOPICID = QQ.TOPICID
WHERE T.PATHID = @PATHID
  AND NOT EXISTS (SELECT 1 FROM dbo.LEARNING_QUIZ_ATTEMPT A WHERE A.QUESTIONID = QQ.QUESTIONID);

DELETE CI
FROM dbo.CONTENT_ITEM CI
INNER JOIN dbo.TOPIC_MASTER T ON T.TOPICID = CI.TOPICID
WHERE T.PATHID = @PATHID
  AND NOT EXISTS (SELECT 1 FROM dbo.DAILY_LEARNING_PLAN P WHERE P.CONTENTID = CI.CONTENTID)
  AND NOT EXISTS (SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER QQ WHERE QQ.CONTENTID = CI.CONTENTID);

/* ---- Topic 1: Arrays & Strings ---- */
IF NOT EXISTS (SELECT 1 FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'ARRAYS_STRINGS')
BEGIN
    INSERT INTO dbo.TOPIC_MASTER
        (PATHID, TOPICKEY, TOPICNAME, DESCRIPTION, DIFFICULTYTIER, DISPLAYORDER,
         PREREQUISITETOPICID, ESTIMATEDMINUTES, THEORYMARKDOWN, ISACTIVE)
    VALUES
        (@PATHID, N'ARRAYS_STRINGS', N'Arrays & Strings', N'Core array and string manipulations from the LeetCode Top Interview 150: in-place edits, prefix products, stock/greedy scans, and string parsing.', N'BEGINNER', 1,
         NULL,
         90, N'# Arrays & Strings (Interview Foundations)

## Why this topic
Most Top Interview 150 warm-ups are array/string problems. Interviewers use them to check **index discipline**, **in-place updates**, and **linear scans** before harder patterns.

## Core techniques
1. **Two-index write pointer** — Remove Element / Remove Duplicates: keep a `write` index for the next valid position while reading with `i`.
2. **Prefix / suffix products** — Product of Array Except Self: left products then right products without division; O(n) time, O(1) extra if output array is allowed.
3. **Single-pass greedy** — Best Time to Buy and Sell Stock: track `minPrice` and `maxProfit` in one left-to-right scan.
4. **Rotate / reverse blocks** — Rotate Array: reverse whole array, then reverse `[0..k)` and `[k..n)`.
5. **String scans** — Length of Last Word, Reverse Words, Longest Common Prefix: careful boundaries and early exits.

## Complexity targets
Aim for **O(n)** time and **O(1)** extra space unless the problem forces a map/set.

## Interview checklist
- Clarify mutation rules (in-place vs new array).
- Watch off-by-one at ends of rotations and reverses.
- State invariants of the write pointer before coding.', 1);
END
ELSE
BEGIN
    UPDATE dbo.TOPIC_MASTER
    SET TOPICNAME = N'Arrays & Strings',
        DESCRIPTION = N'Core array and string manipulations from the LeetCode Top Interview 150: in-place edits, prefix products, stock/greedy scans, and string parsing.',
        DIFFICULTYTIER = N'BEGINNER',
        DISPLAYORDER = 1,
        PREREQUISITETOPICID = NULL,
        ESTIMATEDMINUTES = 90,
        THEORYMARKDOWN = N'# Arrays & Strings (Interview Foundations)

## Why this topic
Most Top Interview 150 warm-ups are array/string problems. Interviewers use them to check **index discipline**, **in-place updates**, and **linear scans** before harder patterns.

## Core techniques
1. **Two-index write pointer** — Remove Element / Remove Duplicates: keep a `write` index for the next valid position while reading with `i`.
2. **Prefix / suffix products** — Product of Array Except Self: left products then right products without division; O(n) time, O(1) extra if output array is allowed.
3. **Single-pass greedy** — Best Time to Buy and Sell Stock: track `minPrice` and `maxProfit` in one left-to-right scan.
4. **Rotate / reverse blocks** — Rotate Array: reverse whole array, then reverse `[0..k)` and `[k..n)`.
5. **String scans** — Length of Last Word, Reverse Words, Longest Common Prefix: careful boundaries and early exits.

## Complexity targets
Aim for **O(n)** time and **O(1)** extra space unless the problem forces a map/set.

## Interview checklist
- Clarify mutation rules (in-place vs new array).
- Watch off-by-one at ends of rotations and reverses.
- State invariants of the write pointer before coding.',
        ISACTIVE = 1,
        UPDATEDDATE = SYSUTCDATETIME()
    WHERE PATHID = @PATHID AND TOPICKEY = N'ARRAYS_STRINGS';
END
SELECT @T_ARRAYS_STRINGS = TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'ARRAYS_STRINGS';

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_ARRAYS_STRINGS AND EXTERNALURL = N'https://leetcode.com/problems/merge-sorted-array/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_ARRAYS_STRINGS, N'PROBLEM', N'Merge Sorted Array', N'Merge nums2 into nums1 in-place from the back.', N'https://leetcode.com/problems/merge-sorted-array/', N'LEETCODE', N'EASY', 1, 20, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Merge Sorted Array', SUMMARY = N'Merge nums2 into nums1 in-place from the back.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 1, ESTIMATEDMINUTES = 20,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_ARRAYS_STRINGS AND EXTERNALURL = N'https://leetcode.com/problems/merge-sorted-array/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_ARRAYS_STRINGS AND EXTERNALURL = N'https://leetcode.com/problems/remove-element/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_ARRAYS_STRINGS, N'PROBLEM', N'Remove Element', N'Two-pointer write compaction for a target value.', N'https://leetcode.com/problems/remove-element/', N'LEETCODE', N'EASY', 2, 15, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Remove Element', SUMMARY = N'Two-pointer write compaction for a target value.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 2, ESTIMATEDMINUTES = 15,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_ARRAYS_STRINGS AND EXTERNALURL = N'https://leetcode.com/problems/remove-element/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_ARRAYS_STRINGS AND EXTERNALURL = N'https://leetcode.com/problems/remove-duplicates-from-sorted-array/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_ARRAYS_STRINGS, N'PROBLEM', N'Remove Duplicates from Sorted Array', N'Keep unique values with a slow write index.', N'https://leetcode.com/problems/remove-duplicates-from-sorted-array/', N'LEETCODE', N'EASY', 3, 20, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Remove Duplicates from Sorted Array', SUMMARY = N'Keep unique values with a slow write index.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 3, ESTIMATEDMINUTES = 20,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_ARRAYS_STRINGS AND EXTERNALURL = N'https://leetcode.com/problems/remove-duplicates-from-sorted-array/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_ARRAYS_STRINGS AND EXTERNALURL = N'https://leetcode.com/problems/majority-element/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_ARRAYS_STRINGS, N'PROBLEM', N'Majority Element', N'Boyer–Moore voting or sort + count.', N'https://leetcode.com/problems/majority-element/', N'LEETCODE', N'EASY', 4, 20, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Majority Element', SUMMARY = N'Boyer–Moore voting or sort + count.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 4, ESTIMATEDMINUTES = 20,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_ARRAYS_STRINGS AND EXTERNALURL = N'https://leetcode.com/problems/majority-element/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_ARRAYS_STRINGS AND EXTERNALURL = N'https://leetcode.com/problems/rotate-array/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_ARRAYS_STRINGS, N'PROBLEM', N'Rotate Array', N'Reverse-based rotation by k steps.', N'https://leetcode.com/problems/rotate-array/', N'LEETCODE', N'MEDIUM', 5, 25, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Rotate Array', SUMMARY = N'Reverse-based rotation by k steps.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 5, ESTIMATEDMINUTES = 25,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_ARRAYS_STRINGS AND EXTERNALURL = N'https://leetcode.com/problems/rotate-array/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_ARRAYS_STRINGS AND EXTERNALURL = N'https://leetcode.com/problems/best-time-to-buy-and-sell-stock/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_ARRAYS_STRINGS, N'PROBLEM', N'Best Time to Buy and Sell Stock', N'Track min buy price and max profit.', N'https://leetcode.com/problems/best-time-to-buy-and-sell-stock/', N'LEETCODE', N'EASY', 6, 20, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Best Time to Buy and Sell Stock', SUMMARY = N'Track min buy price and max profit.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 6, ESTIMATEDMINUTES = 20,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_ARRAYS_STRINGS AND EXTERNALURL = N'https://leetcode.com/problems/best-time-to-buy-and-sell-stock/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_ARRAYS_STRINGS AND EXTERNALURL = N'https://leetcode.com/problems/jump-game/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_ARRAYS_STRINGS, N'PROBLEM', N'Jump Game', N'Greedy farthest reach.', N'https://leetcode.com/problems/jump-game/', N'LEETCODE', N'MEDIUM', 7, 25, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Jump Game', SUMMARY = N'Greedy farthest reach.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 7, ESTIMATEDMINUTES = 25,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_ARRAYS_STRINGS AND EXTERNALURL = N'https://leetcode.com/problems/jump-game/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_ARRAYS_STRINGS AND EXTERNALURL = N'https://leetcode.com/problems/product-of-array-except-self/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_ARRAYS_STRINGS, N'PROBLEM', N'Product of Array Except Self', N'Prefix × suffix without division.', N'https://leetcode.com/problems/product-of-array-except-self/', N'LEETCODE', N'MEDIUM', 8, 30, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Product of Array Except Self', SUMMARY = N'Prefix × suffix without division.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 8, ESTIMATEDMINUTES = 30,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_ARRAYS_STRINGS AND EXTERNALURL = N'https://leetcode.com/problems/product-of-array-except-self/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_ARRAYS_STRINGS AND EXTERNALURL = N'https://leetcode.com/problems/gas-station/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_ARRAYS_STRINGS, N'PROBLEM', N'Gas Station', N'Unique start index when total gas ≥ cost.', N'https://leetcode.com/problems/gas-station/', N'LEETCODE', N'MEDIUM', 9, 30, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Gas Station', SUMMARY = N'Unique start index when total gas ≥ cost.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 9, ESTIMATEDMINUTES = 30,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_ARRAYS_STRINGS AND EXTERNALURL = N'https://leetcode.com/problems/gas-station/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_ARRAYS_STRINGS AND EXTERNALURL = N'https://leetcode.com/problems/trapping-rain-water/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_ARRAYS_STRINGS, N'PROBLEM', N'Trapping Rain Water', N'Two pointers / pref max heights.', N'https://leetcode.com/problems/trapping-rain-water/', N'LEETCODE', N'HARD', 10, 40, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Trapping Rain Water', SUMMARY = N'Two pointers / pref max heights.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'HARD', DISPLAYORDER = 10, ESTIMATEDMINUTES = 40,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_ARRAYS_STRINGS AND EXTERNALURL = N'https://leetcode.com/problems/trapping-rain-water/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_ARRAYS_STRINGS AND EXTERNALURL = N'https://leetcode.com/problems/roman-to-integer/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_ARRAYS_STRINGS, N'PROBLEM', N'Roman to Integer', N'Subtractive notation scan.', N'https://leetcode.com/problems/roman-to-integer/', N'LEETCODE', N'EASY', 11, 15, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Roman to Integer', SUMMARY = N'Subtractive notation scan.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 11, ESTIMATEDMINUTES = 15,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_ARRAYS_STRINGS AND EXTERNALURL = N'https://leetcode.com/problems/roman-to-integer/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_ARRAYS_STRINGS AND EXTERNALURL = N'https://leetcode.com/problems/longest-common-prefix/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_ARRAYS_STRINGS, N'PROBLEM', N'Longest Common Prefix', N'Vertical or horizontal scan.', N'https://leetcode.com/problems/longest-common-prefix/', N'LEETCODE', N'EASY', 12, 15, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Longest Common Prefix', SUMMARY = N'Vertical or horizontal scan.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 12, ESTIMATEDMINUTES = 15,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_ARRAYS_STRINGS AND EXTERNALURL = N'https://leetcode.com/problems/longest-common-prefix/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_ARRAYS_STRINGS AND EXTERNALURL = N'https://leetcode.com/problems/reverse-words-in-a-string/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_ARRAYS_STRINGS, N'PROBLEM', N'Reverse Words in a String', N'Trim, split, reverse word order.', N'https://leetcode.com/problems/reverse-words-in-a-string/', N'LEETCODE', N'MEDIUM', 13, 25, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Reverse Words in a String', SUMMARY = N'Trim, split, reverse word order.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 13, ESTIMATEDMINUTES = 25,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_ARRAYS_STRINGS AND EXTERNALURL = N'https://leetcode.com/problems/reverse-words-in-a-string/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_ARRAYS_STRINGS AND CONTENTTYPE = N'THEORY' AND TITLE = N'Arrays & Strings — Theory')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_ARRAYS_STRINGS, N'THEORY', N'Arrays & Strings — Theory', N'Interview-oriented theory for Arrays & Strings (Top 150 patterns).', NULL, N'STREAKLY', N'MEDIUM', 0, 20, 1);
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_ARRAYS_STRINGS AND DISPLAYORDER = 1 AND QUESTIONTEXT = N'For Remove Element / Remove Duplicates (sorted), what is the purpose of a separate write index?'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_ARRAYS_STRINGS AND QUESTIONTEXT = N'For Remove Element / Remove Duplicates (sorted), what is the purpose of a separate write index?'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_ARRAYS_STRINGS, NULL, N'For Remove Element / Remove Duplicates (sorted), what is the purpose of a separate write index?', N'It marks the next position where a kept value should be written', N'It stores the majority element candidate', N'It computes prefix products', N'It finds the pivot in a rotated array',
         N'A', N'You read with one pointer and compact kept elements via write++ so the prefix [0..write) is the answer.', N'EASY', 1, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'It marks the next position where a kept value should be written', OPTIONB = N'It stores the majority element candidate', OPTIONC = N'It computes prefix products', OPTIOND = N'It finds the pivot in a rotated array',
        CORRECTOPTION = N'A', EXPLANATION = N'You read with one pointer and compact kept elements via write++ so the prefix [0..write) is the answer.', DIFFICULTY = N'EASY',
        DISPLAYORDER = 1, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_ARRAYS_STRINGS AND QUESTIONTEXT = N'For Remove Element / Remove Duplicates (sorted), what is the purpose of a separate write index?';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_ARRAYS_STRINGS AND DISPLAYORDER = 2 AND QUESTIONTEXT = N'Product of Array Except Self without division is typically solved by:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_ARRAYS_STRINGS AND QUESTIONTEXT = N'Product of Array Except Self without division is typically solved by:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_ARRAYS_STRINGS, NULL, N'Product of Array Except Self without division is typically solved by:', N'Sorting then multiplying neighbors', N'Left prefix products combined with right suffix products', N'Binary search on the product', N'Kadane on the absolute values',
         N'B', N'answer[i] = product(left of i) × product(right of i).', N'MEDIUM', 2, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Sorting then multiplying neighbors', OPTIONB = N'Left prefix products combined with right suffix products', OPTIONC = N'Binary search on the product', OPTIOND = N'Kadane on the absolute values',
        CORRECTOPTION = N'B', EXPLANATION = N'answer[i] = product(left of i) × product(right of i).', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 2, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_ARRAYS_STRINGS AND QUESTIONTEXT = N'Product of Array Except Self without division is typically solved by:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_ARRAYS_STRINGS AND DISPLAYORDER = 3 AND QUESTIONTEXT = N'In Best Time to Buy and Sell Stock (one transaction), which state is sufficient?'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_ARRAYS_STRINGS AND QUESTIONTEXT = N'In Best Time to Buy and Sell Stock (one transaction), which state is sufficient?'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_ARRAYS_STRINGS, NULL, N'In Best Time to Buy and Sell Stock (one transaction), which state is sufficient?', N'All pairs i < j compared in O(n²)', N'Running minimum price so far and best profit so far', N'A monotonic decreasing stack of indices only', N'Union-Find of price levels',
         N'B', N'Sell today against the cheapest buy seen earlier.', N'EASY', 3, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'All pairs i < j compared in O(n²)', OPTIONB = N'Running minimum price so far and best profit so far', OPTIONC = N'A monotonic decreasing stack of indices only', OPTIOND = N'Union-Find of price levels',
        CORRECTOPTION = N'B', EXPLANATION = N'Sell today against the cheapest buy seen earlier.', DIFFICULTY = N'EASY',
        DISPLAYORDER = 3, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_ARRAYS_STRINGS AND QUESTIONTEXT = N'In Best Time to Buy and Sell Stock (one transaction), which state is sufficient?';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_ARRAYS_STRINGS AND DISPLAYORDER = 4 AND QUESTIONTEXT = N'Jump Game: why can greedy farthest-reach work in O(n)?'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_ARRAYS_STRINGS AND QUESTIONTEXT = N'Jump Game: why can greedy farthest-reach work in O(n)?'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_ARRAYS_STRINGS, NULL, N'Jump Game: why can greedy farthest-reach work in O(n)?', N'Because jumps form a DAG with unique topological order', N'Because the reachable interval from the start expands monotonically left→right', N'Because the array is always sorted', N'Because DP memoization is O(1) amortized',
         N'B', N'Track the max index reachable; if you pass it before n-1, you fail.', N'MEDIUM', 4, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Because jumps form a DAG with unique topological order', OPTIONB = N'Because the reachable interval from the start expands monotonically left→right', OPTIONC = N'Because the array is always sorted', OPTIOND = N'Because DP memoization is O(1) amortized',
        CORRECTOPTION = N'B', EXPLANATION = N'Track the max index reachable; if you pass it before n-1, you fail.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 4, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_ARRAYS_STRINGS AND QUESTIONTEXT = N'Jump Game: why can greedy farthest-reach work in O(n)?';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_ARRAYS_STRINGS AND DISPLAYORDER = 5 AND QUESTIONTEXT = N'Rotate Array by k using three reverses is correct because:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_ARRAYS_STRINGS AND QUESTIONTEXT = N'Rotate Array by k using three reverses is correct because:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_ARRAYS_STRINGS, NULL, N'Rotate Array by k using three reverses is correct because:', N'Reversals commute with sorting', N'It realizes the cyclic shift identity via block reversals', N'It uses O(k) extra memory only', N'It requires the array to be strictly increasing',
         N'B', N'Classic reverse-whole then reverse two parts implements rotation in O(n) time / O(1) space.', N'MEDIUM', 5, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Reversals commute with sorting', OPTIONB = N'It realizes the cyclic shift identity via block reversals', OPTIONC = N'It uses O(k) extra memory only', OPTIOND = N'It requires the array to be strictly increasing',
        CORRECTOPTION = N'B', EXPLANATION = N'Classic reverse-whole then reverse two parts implements rotation in O(n) time / O(1) space.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 5, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_ARRAYS_STRINGS AND QUESTIONTEXT = N'Rotate Array by k using three reverses is correct because:';
END

/* ---- Topic 2: Two Pointers ---- */
IF NOT EXISTS (SELECT 1 FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'TWO_POINTERS')
BEGIN
    INSERT INTO dbo.TOPIC_MASTER
        (PATHID, TOPICKEY, TOPICNAME, DESCRIPTION, DIFFICULTYTIER, DISPLAYORDER,
         PREREQUISITETOPICID, ESTIMATEDMINUTES, THEORYMARKDOWN, ISACTIVE)
    VALUES
        (@PATHID, N'TWO_POINTERS', N'Two Pointers', N'Paired indices moving toward each other or in the same direction—Top 150 classics like Two Sum II, 3Sum, Container With Most Water, and Valid Palindrome.', N'BEGINNER', 2,
         (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'ARRAYS_STRINGS'),
         75, N'# Two Pointers

## Pattern
Maintain two indices (`L`, `R` or `slow`, `fast`) with a clear **invariant** so each move eliminates candidates.

## Variants in Top 150
- **Opposite ends** — Container With Most Water, Two Sum II (sorted): move the pointer that can improve the objective.
- **Same direction** — Is Subsequence: advance pattern pointer only on matches.
- **Sorted 3Sum** — Sort, fix `i`, then two-sum on the right with skip-duplicates.
- **Palindrome** — Valid Palindrome: skip non-alnum, compare case-insensitive.

## When not to use
Unsorted pairs needing arbitrary lookups → prefer **hash map**. Non-contiguous subsequences with more complex costs → DP.

## Complexity
Usually **O(n)** or **O(n log n)** if you sort first (3Sum).', 1);
END
ELSE
BEGIN
    UPDATE dbo.TOPIC_MASTER
    SET TOPICNAME = N'Two Pointers',
        DESCRIPTION = N'Paired indices moving toward each other or in the same direction—Top 150 classics like Two Sum II, 3Sum, Container With Most Water, and Valid Palindrome.',
        DIFFICULTYTIER = N'BEGINNER',
        DISPLAYORDER = 2,
        PREREQUISITETOPICID = (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'ARRAYS_STRINGS'),
        ESTIMATEDMINUTES = 75,
        THEORYMARKDOWN = N'# Two Pointers

## Pattern
Maintain two indices (`L`, `R` or `slow`, `fast`) with a clear **invariant** so each move eliminates candidates.

## Variants in Top 150
- **Opposite ends** — Container With Most Water, Two Sum II (sorted): move the pointer that can improve the objective.
- **Same direction** — Is Subsequence: advance pattern pointer only on matches.
- **Sorted 3Sum** — Sort, fix `i`, then two-sum on the right with skip-duplicates.
- **Palindrome** — Valid Palindrome: skip non-alnum, compare case-insensitive.

## When not to use
Unsorted pairs needing arbitrary lookups → prefer **hash map**. Non-contiguous subsequences with more complex costs → DP.

## Complexity
Usually **O(n)** or **O(n log n)** if you sort first (3Sum).',
        ISACTIVE = 1,
        UPDATEDDATE = SYSUTCDATETIME()
    WHERE PATHID = @PATHID AND TOPICKEY = N'TWO_POINTERS';
END
SELECT @T_TWO_POINTERS = TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'TWO_POINTERS';

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_TWO_POINTERS AND EXTERNALURL = N'https://leetcode.com/problems/valid-palindrome/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_TWO_POINTERS, N'PROBLEM', N'Valid Palindrome', N'Two pointers skipping non-alphanumeric.', N'https://leetcode.com/problems/valid-palindrome/', N'LEETCODE', N'EASY', 1, 20, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Valid Palindrome', SUMMARY = N'Two pointers skipping non-alphanumeric.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 1, ESTIMATEDMINUTES = 20,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_TWO_POINTERS AND EXTERNALURL = N'https://leetcode.com/problems/valid-palindrome/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_TWO_POINTERS AND EXTERNALURL = N'https://leetcode.com/problems/is-subsequence/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_TWO_POINTERS, N'PROBLEM', N'Is Subsequence', N'Advance pattern pointer on matches.', N'https://leetcode.com/problems/is-subsequence/', N'LEETCODE', N'EASY', 2, 15, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Is Subsequence', SUMMARY = N'Advance pattern pointer on matches.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 2, ESTIMATEDMINUTES = 15,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_TWO_POINTERS AND EXTERNALURL = N'https://leetcode.com/problems/is-subsequence/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_TWO_POINTERS AND EXTERNALURL = N'https://leetcode.com/problems/two-sum-ii-input-array-is-sorted/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_TWO_POINTERS, N'PROBLEM', N'Two Sum II - Input Array Is Sorted', N'Opposite ends on a sorted array.', N'https://leetcode.com/problems/two-sum-ii-input-array-is-sorted/', N'LEETCODE', N'MEDIUM', 3, 20, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Two Sum II - Input Array Is Sorted', SUMMARY = N'Opposite ends on a sorted array.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 3, ESTIMATEDMINUTES = 20,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_TWO_POINTERS AND EXTERNALURL = N'https://leetcode.com/problems/two-sum-ii-input-array-is-sorted/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_TWO_POINTERS AND EXTERNALURL = N'https://leetcode.com/problems/container-with-most-water/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_TWO_POINTERS, N'PROBLEM', N'Container With Most Water', N'Maximize min(height)*width greedily.', N'https://leetcode.com/problems/container-with-most-water/', N'LEETCODE', N'MEDIUM', 4, 25, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Container With Most Water', SUMMARY = N'Maximize min(height)*width greedily.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 4, ESTIMATEDMINUTES = 25,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_TWO_POINTERS AND EXTERNALURL = N'https://leetcode.com/problems/container-with-most-water/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_TWO_POINTERS AND EXTERNALURL = N'https://leetcode.com/problems/3sum/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_TWO_POINTERS, N'PROBLEM', N'3Sum', N'Sort + fix i + two pointers; skip duplicates.', N'https://leetcode.com/problems/3sum/', N'LEETCODE', N'MEDIUM', 5, 35, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'3Sum', SUMMARY = N'Sort + fix i + two pointers; skip duplicates.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 5, ESTIMATEDMINUTES = 35,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_TWO_POINTERS AND EXTERNALURL = N'https://leetcode.com/problems/3sum/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_TWO_POINTERS AND CONTENTTYPE = N'THEORY' AND TITLE = N'Two Pointers — Theory')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_TWO_POINTERS, N'THEORY', N'Two Pointers — Theory', N'Interview-oriented theory for Two Pointers (Top 150 patterns).', NULL, N'STREAKLY', N'MEDIUM', 0, 20, 1);
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_TWO_POINTERS AND DISPLAYORDER = 1 AND QUESTIONTEXT = N'On a sorted array, Two Sum II moves pointers based on:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_TWO_POINTERS AND QUESTIONTEXT = N'On a sorted array, Two Sum II moves pointers based on:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_TWO_POINTERS, NULL, N'On a sorted array, Two Sum II moves pointers based on:', N'Hash collisions', N'Whether current sum is less/greater than target', N'Random sampling', N'BFS layers',
         N'B', N'Increase L if sum too small; decrease R if sum too large.', N'EASY', 1, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Hash collisions', OPTIONB = N'Whether current sum is less/greater than target', OPTIONC = N'Random sampling', OPTIOND = N'BFS layers',
        CORRECTOPTION = N'B', EXPLANATION = N'Increase L if sum too small; decrease R if sum too large.', DIFFICULTY = N'EASY',
        DISPLAYORDER = 1, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_TWO_POINTERS AND QUESTIONTEXT = N'On a sorted array, Two Sum II moves pointers based on:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_TWO_POINTERS AND DISPLAYORDER = 2 AND QUESTIONTEXT = N'In Container With Most Water, why move the shorter line inward?'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_TWO_POINTERS AND QUESTIONTEXT = N'In Container With Most Water, why move the shorter line inward?'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_TWO_POINTERS, NULL, N'In Container With Most Water, why move the shorter line inward?', N'Width always increases that way', N'Height is fixed by the shorter line; only a taller candidate can improve area', N'It guarantees a local maximum only', N'Because the array must be bitonic',
         N'B', N'Area = min(hL,hR)*(R-L); moving the taller side cannot increase min height.', N'MEDIUM', 2, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Width always increases that way', OPTIONB = N'Height is fixed by the shorter line; only a taller candidate can improve area', OPTIONC = N'It guarantees a local maximum only', OPTIOND = N'Because the array must be bitonic',
        CORRECTOPTION = N'B', EXPLANATION = N'Area = min(hL,hR)*(R-L); moving the taller side cannot increase min height.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 2, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_TWO_POINTERS AND QUESTIONTEXT = N'In Container With Most Water, why move the shorter line inward?';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_TWO_POINTERS AND DISPLAYORDER = 3 AND QUESTIONTEXT = N'3Sum after sorting uses two pointers primarily to:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_TWO_POINTERS AND QUESTIONTEXT = N'3Sum after sorting uses two pointers primarily to:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_TWO_POINTERS, NULL, N'3Sum after sorting uses two pointers primarily to:', N'Avoid O(n³) while handling duplicates carefully', N'Replace sorting entirely', N'Compute FFT convolution', N'Build a segment tree',
         N'A', N'Fix one index, solve two-sum on the remainder in linear time; skip equal values.', N'MEDIUM', 3, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Avoid O(n³) while handling duplicates carefully', OPTIONB = N'Replace sorting entirely', OPTIONC = N'Compute FFT convolution', OPTIOND = N'Build a segment tree',
        CORRECTOPTION = N'A', EXPLANATION = N'Fix one index, solve two-sum on the remainder in linear time; skip equal values.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 3, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_TWO_POINTERS AND QUESTIONTEXT = N'3Sum after sorting uses two pointers primarily to:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_TWO_POINTERS AND DISPLAYORDER = 4 AND QUESTIONTEXT = N'Is Subsequence two-pointer approach advances the pattern index when:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_TWO_POINTERS AND QUESTIONTEXT = N'Is Subsequence two-pointer approach advances the pattern index when:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_TWO_POINTERS, NULL, N'Is Subsequence two-pointer approach advances the pattern index when:', N'Characters mismatch', N'Characters match', N'Indices are equal', N'The text is sorted',
         N'B', N'Only matches consume the next required character of the pattern.', N'EASY', 4, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Characters mismatch', OPTIONB = N'Characters match', OPTIONC = N'Indices are equal', OPTIOND = N'The text is sorted',
        CORRECTOPTION = N'B', EXPLANATION = N'Only matches consume the next required character of the pattern.', DIFFICULTY = N'EASY',
        DISPLAYORDER = 4, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_TWO_POINTERS AND QUESTIONTEXT = N'Is Subsequence two-pointer approach advances the pattern index when:';
END

/* ---- Topic 3: Sliding Window ---- */
IF NOT EXISTS (SELECT 1 FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'SLIDING_WINDOW')
BEGIN
    INSERT INTO dbo.TOPIC_MASTER
        (PATHID, TOPICKEY, TOPICNAME, DESCRIPTION, DIFFICULTYTIER, DISPLAYORDER,
         PREREQUISITETOPICID, ESTIMATEDMINUTES, THEORYMARKDOWN, ISACTIVE)
    VALUES
        (@PATHID, N'SLIDING_WINDOW', N'Sliding Window', N'Contiguous subarray/substring constraints: Minimum Size Subarray Sum, Longest Substring Without Repeating Characters, and Minimum Window Substring from Top 150.', N'INTERMEDIATE', 3,
         (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'TWO_POINTERS'),
         80, N'# Sliding Window

## Idea
Maintain a window `[L, R]` over a contiguous range. Expand `R` to include candidates; shrink `L` when a constraint is violated or when optimizing.

## Top 150 exemplars
- **Minimum Size Subarray Sum** — expand until sum ≥ target, then shrink for minimal length (positive numbers).
- **Longest Substring Without Repeating Characters** — window with last-seen index / count map.
- **Minimum Window Substring** — need-count map; shrink when all required chars are satisfied.

## Fixed vs variable
Fixed size updates aggregates in O(1) per step. Variable size needs a clear **validity predicate**.

## Pitfalls
- Off-by-one on inclusive bounds.
- Forgetting to update the map when shrinking.
- Applying positive-sum shrink logic to arrays with negatives (won''t work).', 1);
END
ELSE
BEGIN
    UPDATE dbo.TOPIC_MASTER
    SET TOPICNAME = N'Sliding Window',
        DESCRIPTION = N'Contiguous subarray/substring constraints: Minimum Size Subarray Sum, Longest Substring Without Repeating Characters, and Minimum Window Substring from Top 150.',
        DIFFICULTYTIER = N'INTERMEDIATE',
        DISPLAYORDER = 3,
        PREREQUISITETOPICID = (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'TWO_POINTERS'),
        ESTIMATEDMINUTES = 80,
        THEORYMARKDOWN = N'# Sliding Window

## Idea
Maintain a window `[L, R]` over a contiguous range. Expand `R` to include candidates; shrink `L` when a constraint is violated or when optimizing.

## Top 150 exemplars
- **Minimum Size Subarray Sum** — expand until sum ≥ target, then shrink for minimal length (positive numbers).
- **Longest Substring Without Repeating Characters** — window with last-seen index / count map.
- **Minimum Window Substring** — need-count map; shrink when all required chars are satisfied.

## Fixed vs variable
Fixed size updates aggregates in O(1) per step. Variable size needs a clear **validity predicate**.

## Pitfalls
- Off-by-one on inclusive bounds.
- Forgetting to update the map when shrinking.
- Applying positive-sum shrink logic to arrays with negatives (won''t work).',
        ISACTIVE = 1,
        UPDATEDDATE = SYSUTCDATETIME()
    WHERE PATHID = @PATHID AND TOPICKEY = N'SLIDING_WINDOW';
END
SELECT @T_SLIDING_WINDOW = TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'SLIDING_WINDOW';

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_SLIDING_WINDOW AND EXTERNALURL = N'https://leetcode.com/problems/minimum-size-subarray-sum/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_SLIDING_WINDOW, N'PROBLEM', N'Minimum Size Subarray Sum', N'Shortest subarray with sum ≥ target (positives).', N'https://leetcode.com/problems/minimum-size-subarray-sum/', N'LEETCODE', N'MEDIUM', 1, 30, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Minimum Size Subarray Sum', SUMMARY = N'Shortest subarray with sum ≥ target (positives).', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 1, ESTIMATEDMINUTES = 30,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_SLIDING_WINDOW AND EXTERNALURL = N'https://leetcode.com/problems/minimum-size-subarray-sum/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_SLIDING_WINDOW AND EXTERNALURL = N'https://leetcode.com/problems/longest-substring-without-repeating-characters/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_SLIDING_WINDOW, N'PROBLEM', N'Longest Substring Without Repeating Characters', N'Window + last index / frequency map.', N'https://leetcode.com/problems/longest-substring-without-repeating-characters/', N'LEETCODE', N'MEDIUM', 2, 30, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Longest Substring Without Repeating Characters', SUMMARY = N'Window + last index / frequency map.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 2, ESTIMATEDMINUTES = 30,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_SLIDING_WINDOW AND EXTERNALURL = N'https://leetcode.com/problems/longest-substring-without-repeating-characters/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_SLIDING_WINDOW AND EXTERNALURL = N'https://leetcode.com/problems/substring-with-concatenation-of-all-words/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_SLIDING_WINDOW, N'PROBLEM', N'Substring with Concatenation of All Words', N'Word-size sliding windows + maps.', N'https://leetcode.com/problems/substring-with-concatenation-of-all-words/', N'LEETCODE', N'HARD', 3, 45, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Substring with Concatenation of All Words', SUMMARY = N'Word-size sliding windows + maps.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'HARD', DISPLAYORDER = 3, ESTIMATEDMINUTES = 45,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_SLIDING_WINDOW AND EXTERNALURL = N'https://leetcode.com/problems/substring-with-concatenation-of-all-words/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_SLIDING_WINDOW AND EXTERNALURL = N'https://leetcode.com/problems/minimum-window-substring/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_SLIDING_WINDOW, N'PROBLEM', N'Minimum Window Substring', N'Smallest window covering all of t.', N'https://leetcode.com/problems/minimum-window-substring/', N'LEETCODE', N'HARD', 4, 45, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Minimum Window Substring', SUMMARY = N'Smallest window covering all of t.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'HARD', DISPLAYORDER = 4, ESTIMATEDMINUTES = 45,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_SLIDING_WINDOW AND EXTERNALURL = N'https://leetcode.com/problems/minimum-window-substring/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_SLIDING_WINDOW AND CONTENTTYPE = N'THEORY' AND TITLE = N'Sliding Window — Theory')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_SLIDING_WINDOW, N'THEORY', N'Sliding Window — Theory', N'Interview-oriented theory for Sliding Window (Top 150 patterns).', NULL, N'STREAKLY', N'MEDIUM', 0, 20, 1);
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_SLIDING_WINDOW AND DISPLAYORDER = 1 AND QUESTIONTEXT = N'Variable sliding window is preferred when:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_SLIDING_WINDOW AND QUESTIONTEXT = N'Variable sliding window is preferred when:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_SLIDING_WINDOW, NULL, N'Variable sliding window is preferred when:', N'You need contiguous subarrays/substrings with a maintainable constraint', N'The array is a binary tree', N'You must process non-contiguous subsequences only', N'n ≤ 5 always',
         N'A', N'Amortized O(n) when each index enters/leaves the window at most once.', N'EASY', 1, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'You need contiguous subarrays/substrings with a maintainable constraint', OPTIONB = N'The array is a binary tree', OPTIONC = N'You must process non-contiguous subsequences only', OPTIOND = N'n ≤ 5 always',
        CORRECTOPTION = N'A', EXPLANATION = N'Amortized O(n) when each index enters/leaves the window at most once.', DIFFICULTY = N'EASY',
        DISPLAYORDER = 1, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_SLIDING_WINDOW AND QUESTIONTEXT = N'Variable sliding window is preferred when:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_SLIDING_WINDOW AND DISPLAYORDER = 2 AND QUESTIONTEXT = N'Minimum Size Subarray Sum (positive integers) shrinks L when:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_SLIDING_WINDOW AND QUESTIONTEXT = N'Minimum Size Subarray Sum (positive integers) shrinks L when:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_SLIDING_WINDOW, NULL, N'Minimum Size Subarray Sum (positive integers) shrinks L when:', N'sum < target', N'sum ≥ target (to minimize length)', N'R reaches n', N'A duplicate appears',
         N'B', N'Once valid, shrink to find the shortest valid window ending at R.', N'MEDIUM', 2, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'sum < target', OPTIONB = N'sum ≥ target (to minimize length)', OPTIONC = N'R reaches n', OPTIOND = N'A duplicate appears',
        CORRECTOPTION = N'B', EXPLANATION = N'Once valid, shrink to find the shortest valid window ending at R.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 2, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_SLIDING_WINDOW AND QUESTIONTEXT = N'Minimum Size Subarray Sum (positive integers) shrinks L when:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_SLIDING_WINDOW AND DISPLAYORDER = 3 AND QUESTIONTEXT = N'Longest Substring Without Repeating Characters typically stores:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_SLIDING_WINDOW AND QUESTIONTEXT = N'Longest Substring Without Repeating Characters typically stores:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_SLIDING_WINDOW, NULL, N'Longest Substring Without Repeating Characters typically stores:', N'A segment tree of ASCII', N'Counts or last-seen indices of characters in the current window', N'Union-Find of characters', N'A priority queue of lengths',
         N'B', N'Detect duplicates inside the window in O(1) per character.', N'EASY', 3, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'A segment tree of ASCII', OPTIONB = N'Counts or last-seen indices of characters in the current window', OPTIONC = N'Union-Find of characters', OPTIOND = N'A priority queue of lengths',
        CORRECTOPTION = N'B', EXPLANATION = N'Detect duplicates inside the window in O(1) per character.', DIFFICULTY = N'EASY',
        DISPLAYORDER = 3, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_SLIDING_WINDOW AND QUESTIONTEXT = N'Longest Substring Without Repeating Characters typically stores:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_SLIDING_WINDOW AND DISPLAYORDER = 4 AND QUESTIONTEXT = N'Minimum Window Substring needs a ''formed'' counter to:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_SLIDING_WINDOW AND QUESTIONTEXT = N'Minimum Window Substring needs a ''formed'' counter to:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_SLIDING_WINDOW, NULL, N'Minimum Window Substring needs a ''formed'' counter to:', N'Count total characters in s only', N'Know when every required character type meets its needed frequency', N'Sort t', N'Hash the entire string s',
         N'B', N'Shrink only while the window remains ''valid'' (all needs satisfied).', N'HARD', 4, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Count total characters in s only', OPTIONB = N'Know when every required character type meets its needed frequency', OPTIONC = N'Sort t', OPTIOND = N'Hash the entire string s',
        CORRECTOPTION = N'B', EXPLANATION = N'Shrink only while the window remains ''valid'' (all needs satisfied).', DIFFICULTY = N'HARD',
        DISPLAYORDER = 4, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_SLIDING_WINDOW AND QUESTIONTEXT = N'Minimum Window Substring needs a ''formed'' counter to:';
END

/* ---- Topic 4: Hash Map ---- */
IF NOT EXISTS (SELECT 1 FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'HASH_MAP')
BEGIN
    INSERT INTO dbo.TOPIC_MASTER
        (PATHID, TOPICKEY, TOPICNAME, DESCRIPTION, DIFFICULTYTIER, DISPLAYORDER,
         PREREQUISITETOPICID, ESTIMATEDMINUTES, THEORYMARKDOWN, ISACTIVE)
    VALUES
        (@PATHID, N'HASH_MAP', N'Hash Map', N'Frequency maps, indexing, and O(1) lookups: Two Sum, Group Anagrams, Happy Number, Contains Duplicate II, Longest Consecutive Sequence.', N'BEGINNER', 4,
         (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'SLIDING_WINDOW'),
         70, N'# Hash Map

## Role in interviews
Trade space for average **O(1)** insert/lookup. Many Top 150 “easy/medium” problems become trivial with a map.

## Patterns
- **Complement lookup** — Two Sum: store value→index; query `target - x`.
- **Canonical key** — Group Anagrams: sorted string or 26-count signature as key.
- **Windowed index map** — Contains Duplicate II: last index within distance k.
- **Set growth** — Longest Consecutive Sequence: put all in a set; only start chains from numbers without `x-1`.

## Complexity note
Average O(1); worst-case hashing rare in interviews—state the assumption.', 1);
END
ELSE
BEGIN
    UPDATE dbo.TOPIC_MASTER
    SET TOPICNAME = N'Hash Map',
        DESCRIPTION = N'Frequency maps, indexing, and O(1) lookups: Two Sum, Group Anagrams, Happy Number, Contains Duplicate II, Longest Consecutive Sequence.',
        DIFFICULTYTIER = N'BEGINNER',
        DISPLAYORDER = 4,
        PREREQUISITETOPICID = (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'SLIDING_WINDOW'),
        ESTIMATEDMINUTES = 70,
        THEORYMARKDOWN = N'# Hash Map

## Role in interviews
Trade space for average **O(1)** insert/lookup. Many Top 150 “easy/medium” problems become trivial with a map.

## Patterns
- **Complement lookup** — Two Sum: store value→index; query `target - x`.
- **Canonical key** — Group Anagrams: sorted string or 26-count signature as key.
- **Windowed index map** — Contains Duplicate II: last index within distance k.
- **Set growth** — Longest Consecutive Sequence: put all in a set; only start chains from numbers without `x-1`.

## Complexity note
Average O(1); worst-case hashing rare in interviews—state the assumption.',
        ISACTIVE = 1,
        UPDATEDDATE = SYSUTCDATETIME()
    WHERE PATHID = @PATHID AND TOPICKEY = N'HASH_MAP';
END
SELECT @T_HASH_MAP = TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'HASH_MAP';

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_HASH_MAP AND EXTERNALURL = N'https://leetcode.com/problems/ransom-note/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_HASH_MAP, N'PROBLEM', N'Ransom Note', N'Frequency of magazine covers note.', N'https://leetcode.com/problems/ransom-note/', N'LEETCODE', N'EASY', 1, 15, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Ransom Note', SUMMARY = N'Frequency of magazine covers note.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 1, ESTIMATEDMINUTES = 15,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_HASH_MAP AND EXTERNALURL = N'https://leetcode.com/problems/ransom-note/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_HASH_MAP AND EXTERNALURL = N'https://leetcode.com/problems/isomorphic-strings/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_HASH_MAP, N'PROBLEM', N'Isomorphic Strings', N'Bijection via two maps or encode pattern.', N'https://leetcode.com/problems/isomorphic-strings/', N'LEETCODE', N'EASY', 2, 20, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Isomorphic Strings', SUMMARY = N'Bijection via two maps or encode pattern.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 2, ESTIMATEDMINUTES = 20,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_HASH_MAP AND EXTERNALURL = N'https://leetcode.com/problems/isomorphic-strings/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_HASH_MAP AND EXTERNALURL = N'https://leetcode.com/problems/word-pattern/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_HASH_MAP, N'PROBLEM', N'Word Pattern', N'Bijection between pattern chars and words.', N'https://leetcode.com/problems/word-pattern/', N'LEETCODE', N'EASY', 3, 20, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Word Pattern', SUMMARY = N'Bijection between pattern chars and words.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 3, ESTIMATEDMINUTES = 20,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_HASH_MAP AND EXTERNALURL = N'https://leetcode.com/problems/word-pattern/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_HASH_MAP AND EXTERNALURL = N'https://leetcode.com/problems/valid-anagram/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_HASH_MAP, N'PROBLEM', N'Valid Anagram', N'Count array / map equality.', N'https://leetcode.com/problems/valid-anagram/', N'LEETCODE', N'EASY', 4, 15, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Valid Anagram', SUMMARY = N'Count array / map equality.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 4, ESTIMATEDMINUTES = 15,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_HASH_MAP AND EXTERNALURL = N'https://leetcode.com/problems/valid-anagram/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_HASH_MAP AND EXTERNALURL = N'https://leetcode.com/problems/group-anagrams/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_HASH_MAP, N'PROBLEM', N'Group Anagrams', N'Hash by sorted key or count tuple.', N'https://leetcode.com/problems/group-anagrams/', N'LEETCODE', N'MEDIUM', 5, 25, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Group Anagrams', SUMMARY = N'Hash by sorted key or count tuple.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 5, ESTIMATEDMINUTES = 25,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_HASH_MAP AND EXTERNALURL = N'https://leetcode.com/problems/group-anagrams/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_HASH_MAP AND EXTERNALURL = N'https://leetcode.com/problems/two-sum/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_HASH_MAP, N'PROBLEM', N'Two Sum', N'One-pass complement map.', N'https://leetcode.com/problems/two-sum/', N'LEETCODE', N'EASY', 6, 15, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Two Sum', SUMMARY = N'One-pass complement map.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 6, ESTIMATEDMINUTES = 15,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_HASH_MAP AND EXTERNALURL = N'https://leetcode.com/problems/two-sum/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_HASH_MAP AND EXTERNALURL = N'https://leetcode.com/problems/happy-number/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_HASH_MAP, N'PROBLEM', N'Happy Number', N'Seen set of sums of squares.', N'https://leetcode.com/problems/happy-number/', N'LEETCODE', N'EASY', 7, 20, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Happy Number', SUMMARY = N'Seen set of sums of squares.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 7, ESTIMATEDMINUTES = 20,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_HASH_MAP AND EXTERNALURL = N'https://leetcode.com/problems/happy-number/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_HASH_MAP AND EXTERNALURL = N'https://leetcode.com/problems/contains-duplicate-ii/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_HASH_MAP, N'PROBLEM', N'Contains Duplicate II', N'Index map with distance ≤ k.', N'https://leetcode.com/problems/contains-duplicate-ii/', N'LEETCODE', N'EASY', 8, 20, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Contains Duplicate II', SUMMARY = N'Index map with distance ≤ k.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 8, ESTIMATEDMINUTES = 20,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_HASH_MAP AND EXTERNALURL = N'https://leetcode.com/problems/contains-duplicate-ii/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_HASH_MAP AND EXTERNALURL = N'https://leetcode.com/problems/longest-consecutive-sequence/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_HASH_MAP, N'PROBLEM', N'Longest Consecutive Sequence', N'Set + start-of-chain expansion O(n).', N'https://leetcode.com/problems/longest-consecutive-sequence/', N'LEETCODE', N'MEDIUM', 9, 30, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Longest Consecutive Sequence', SUMMARY = N'Set + start-of-chain expansion O(n).', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 9, ESTIMATEDMINUTES = 30,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_HASH_MAP AND EXTERNALURL = N'https://leetcode.com/problems/longest-consecutive-sequence/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_HASH_MAP AND CONTENTTYPE = N'THEORY' AND TITLE = N'Hash Map — Theory')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_HASH_MAP, N'THEORY', N'Hash Map — Theory', N'Interview-oriented theory for Hash Map (Top 150 patterns).', NULL, N'STREAKLY', N'MEDIUM', 0, 20, 1);
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_HASH_MAP AND DISPLAYORDER = 1 AND QUESTIONTEXT = N'Two Sum one-pass hash map stores:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_HASH_MAP AND QUESTIONTEXT = N'Two Sum one-pass hash map stores:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_HASH_MAP, NULL, N'Two Sum one-pass hash map stores:', N'Only sorted unique values', N'Value → index of numbers seen so far', N'Prefix XOR only', N'A Fenwick tree of indices',
         N'B', N'For each x, look up target−x before inserting x.', N'EASY', 1, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Only sorted unique values', OPTIONB = N'Value → index of numbers seen so far', OPTIONC = N'Prefix XOR only', OPTIOND = N'A Fenwick tree of indices',
        CORRECTOPTION = N'B', EXPLANATION = N'For each x, look up target−x before inserting x.', DIFFICULTY = N'EASY',
        DISPLAYORDER = 1, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_HASH_MAP AND QUESTIONTEXT = N'Two Sum one-pass hash map stores:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_HASH_MAP AND DISPLAYORDER = 2 AND QUESTIONTEXT = N'Group Anagrams keys are equal iff:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_HASH_MAP AND QUESTIONTEXT = N'Group Anagrams keys are equal iff:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_HASH_MAP, NULL, N'Group Anagrams keys are equal iff:', N'Strings have the same length only', N'Strings share the same character multiset', N'Strings are rotations', N'Strings are palindromes',
         N'B', N'Sorted form or 26-letter count vector identifies anagram classes.', N'EASY', 2, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Strings have the same length only', OPTIONB = N'Strings share the same character multiset', OPTIONC = N'Strings are rotations', OPTIOND = N'Strings are palindromes',
        CORRECTOPTION = N'B', EXPLANATION = N'Sorted form or 26-letter count vector identifies anagram classes.', DIFFICULTY = N'EASY',
        DISPLAYORDER = 2, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_HASH_MAP AND QUESTIONTEXT = N'Group Anagrams keys are equal iff:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_HASH_MAP AND DISPLAYORDER = 3 AND QUESTIONTEXT = N'Longest Consecutive Sequence achieves O(n) by:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_HASH_MAP AND QUESTIONTEXT = N'Longest Consecutive Sequence achieves O(n) by:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_HASH_MAP, NULL, N'Longest Consecutive Sequence achieves O(n) by:', N'Sorting then scanning', N'Only expanding sequences from numbers that have no predecessor in the set', N'Segment trees over value range', N'Dijkstra on a number graph',
         N'B', N'Each number is visited a constant number of times across all expansions.', N'MEDIUM', 3, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Sorting then scanning', OPTIONB = N'Only expanding sequences from numbers that have no predecessor in the set', OPTIONC = N'Segment trees over value range', OPTIOND = N'Dijkstra on a number graph',
        CORRECTOPTION = N'B', EXPLANATION = N'Each number is visited a constant number of times across all expansions.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 3, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_HASH_MAP AND QUESTIONTEXT = N'Longest Consecutive Sequence achieves O(n) by:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_HASH_MAP AND DISPLAYORDER = 4 AND QUESTIONTEXT = N'Isomorphic Strings requires:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_HASH_MAP AND QUESTIONTEXT = N'Isomorphic Strings requires:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_HASH_MAP, NULL, N'Isomorphic Strings requires:', N'A one-way mapping only from s→t', N'A consistent bijection (no two letters mapping to the same target inconsistently)', N'Both strings sorted', N'Equal vowel counts only',
         N'B', N'Use two maps or ensure reverse mapping uniqueness.', N'MEDIUM', 4, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'A one-way mapping only from s→t', OPTIONB = N'A consistent bijection (no two letters mapping to the same target inconsistently)', OPTIONC = N'Both strings sorted', OPTIOND = N'Equal vowel counts only',
        CORRECTOPTION = N'B', EXPLANATION = N'Use two maps or ensure reverse mapping uniqueness.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 4, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_HASH_MAP AND QUESTIONTEXT = N'Isomorphic Strings requires:';
END

/* ---- Topic 5: Intervals ---- */
IF NOT EXISTS (SELECT 1 FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'INTERVALS')
BEGIN
    INSERT INTO dbo.TOPIC_MASTER
        (PATHID, TOPICKEY, TOPICNAME, DESCRIPTION, DIFFICULTYTIER, DISPLAYORDER,
         PREREQUISITETOPICID, ESTIMATEDMINUTES, THEORYMARKDOWN, ISACTIVE)
    VALUES
        (@PATHID, N'INTERVALS', N'Intervals', N'Sort-and-sweep interval problems: Summary Ranges, Merge Intervals, Insert Interval, and Minimum Number of Arrows to Burst Balloons.', N'INTERMEDIATE', 5,
         (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'HASH_MAP'),
         60, N'# Intervals

## Standard pipeline
1. Sort by start (sometimes by end).
2. Sweep while merging overlaps or counting conflicts.

## Top 150
- **Merge Intervals** — if `cur.start ≤ last.end`, merge ends; else push new.
- **Insert Interval** — linear scan: add before, merge overlapping, append after.
- **Minimum Arrows** — sort by end; greedy shoot at end of current balloon cluster.

## Proof sketch (arrows)
Sorting by end and always shooting at the earliest finishing interval is optimal for covering intervals on a line.', 1);
END
ELSE
BEGIN
    UPDATE dbo.TOPIC_MASTER
    SET TOPICNAME = N'Intervals',
        DESCRIPTION = N'Sort-and-sweep interval problems: Summary Ranges, Merge Intervals, Insert Interval, and Minimum Number of Arrows to Burst Balloons.',
        DIFFICULTYTIER = N'INTERMEDIATE',
        DISPLAYORDER = 5,
        PREREQUISITETOPICID = (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'HASH_MAP'),
        ESTIMATEDMINUTES = 60,
        THEORYMARKDOWN = N'# Intervals

## Standard pipeline
1. Sort by start (sometimes by end).
2. Sweep while merging overlaps or counting conflicts.

## Top 150
- **Merge Intervals** — if `cur.start ≤ last.end`, merge ends; else push new.
- **Insert Interval** — linear scan: add before, merge overlapping, append after.
- **Minimum Arrows** — sort by end; greedy shoot at end of current balloon cluster.

## Proof sketch (arrows)
Sorting by end and always shooting at the earliest finishing interval is optimal for covering intervals on a line.',
        ISACTIVE = 1,
        UPDATEDDATE = SYSUTCDATETIME()
    WHERE PATHID = @PATHID AND TOPICKEY = N'INTERVALS';
END
SELECT @T_INTERVALS = TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'INTERVALS';

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_INTERVALS AND EXTERNALURL = N'https://leetcode.com/problems/summary-ranges/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_INTERVALS, N'PROBLEM', N'Summary Ranges', N'Compress consecutive sorted numbers.', N'https://leetcode.com/problems/summary-ranges/', N'LEETCODE', N'EASY', 1, 15, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Summary Ranges', SUMMARY = N'Compress consecutive sorted numbers.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 1, ESTIMATEDMINUTES = 15,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_INTERVALS AND EXTERNALURL = N'https://leetcode.com/problems/summary-ranges/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_INTERVALS AND EXTERNALURL = N'https://leetcode.com/problems/merge-intervals/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_INTERVALS, N'PROBLEM', N'Merge Intervals', N'Sort by start; merge overlaps.', N'https://leetcode.com/problems/merge-intervals/', N'LEETCODE', N'MEDIUM', 2, 25, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Merge Intervals', SUMMARY = N'Sort by start; merge overlaps.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 2, ESTIMATEDMINUTES = 25,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_INTERVALS AND EXTERNALURL = N'https://leetcode.com/problems/merge-intervals/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_INTERVALS AND EXTERNALURL = N'https://leetcode.com/problems/insert-interval/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_INTERVALS, N'PROBLEM', N'Insert Interval', N'Insert then merge overlapping range.', N'https://leetcode.com/problems/insert-interval/', N'LEETCODE', N'MEDIUM', 3, 30, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Insert Interval', SUMMARY = N'Insert then merge overlapping range.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 3, ESTIMATEDMINUTES = 30,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_INTERVALS AND EXTERNALURL = N'https://leetcode.com/problems/insert-interval/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_INTERVALS AND EXTERNALURL = N'https://leetcode.com/problems/minimum-number-of-arrows-to-burst-balloons/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_INTERVALS, N'PROBLEM', N'Minimum Number of Arrows to Burst Balloons', N'Greedy by end points.', N'https://leetcode.com/problems/minimum-number-of-arrows-to-burst-balloons/', N'LEETCODE', N'MEDIUM', 4, 30, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Minimum Number of Arrows to Burst Balloons', SUMMARY = N'Greedy by end points.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 4, ESTIMATEDMINUTES = 30,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_INTERVALS AND EXTERNALURL = N'https://leetcode.com/problems/minimum-number-of-arrows-to-burst-balloons/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_INTERVALS AND CONTENTTYPE = N'THEORY' AND TITLE = N'Intervals — Theory')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_INTERVALS, N'THEORY', N'Intervals — Theory', N'Interview-oriented theory for Intervals (Top 150 patterns).', NULL, N'STREAKLY', N'MEDIUM', 0, 20, 1);
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_INTERVALS AND DISPLAYORDER = 1 AND QUESTIONTEXT = N'Merge Intervals first step is almost always:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_INTERVALS AND QUESTIONTEXT = N'Merge Intervals first step is almost always:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_INTERVALS, NULL, N'Merge Intervals first step is almost always:', N'Sort intervals by start time', N'Build a segment tree', N'Hash all endpoints', N'Run Dijkstra',
         N'A', N'Sorting enables a single linear merge pass.', N'EASY', 1, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Sort intervals by start time', OPTIONB = N'Build a segment tree', OPTIONC = N'Hash all endpoints', OPTIOND = N'Run Dijkstra',
        CORRECTOPTION = N'A', EXPLANATION = N'Sorting enables a single linear merge pass.', DIFFICULTY = N'EASY',
        DISPLAYORDER = 1, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_INTERVALS AND QUESTIONTEXT = N'Merge Intervals first step is almost always:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_INTERVALS AND DISPLAYORDER = 2 AND QUESTIONTEXT = N'Two intervals [a,b] and [c,d] (a≤c) overlap when:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_INTERVALS AND QUESTIONTEXT = N'Two intervals [a,b] and [c,d] (a≤c) overlap when:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_INTERVALS, NULL, N'Two intervals [a,b] and [c,d] (a≤c) overlap when:', N'b < c', N'c ≤ b', N'a == d', N'Always',
         N'B', N'If the next start is ≤ current end, they intersect or touch (problem-dependent on touching).', N'EASY', 2, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'b < c', OPTIONB = N'c ≤ b', OPTIONC = N'a == d', OPTIOND = N'Always',
        CORRECTOPTION = N'B', EXPLANATION = N'If the next start is ≤ current end, they intersect or touch (problem-dependent on touching).', DIFFICULTY = N'EASY',
        DISPLAYORDER = 2, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_INTERVALS AND QUESTIONTEXT = N'Two intervals [a,b] and [c,d] (a≤c) overlap when:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_INTERVALS AND DISPLAYORDER = 3 AND QUESTIONTEXT = N'Minimum arrows greedy sorts by:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_INTERVALS AND QUESTIONTEXT = N'Minimum arrows greedy sorts by:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_INTERVALS, NULL, N'Minimum arrows greedy sorts by:', N'Interval length ascending', N'Ending coordinate ascending', N'Starting coordinate descending', N'Random order',
         N'B', N'Shoot at the end of the earliest-ending balloon still active.', N'MEDIUM', 3, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Interval length ascending', OPTIONB = N'Ending coordinate ascending', OPTIONC = N'Starting coordinate descending', OPTIOND = N'Random order',
        CORRECTOPTION = N'B', EXPLANATION = N'Shoot at the end of the earliest-ending balloon still active.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 3, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_INTERVALS AND QUESTIONTEXT = N'Minimum arrows greedy sorts by:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_INTERVALS AND DISPLAYORDER = 4 AND QUESTIONTEXT = N'Insert Interval can be done in one pass by:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_INTERVALS AND QUESTIONTEXT = N'Insert Interval can be done in one pass by:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_INTERVALS, NULL, N'Insert Interval can be done in one pass by:', N'Only binary searching the middle', N'Emitting non-overlapping left, merging overlap region, then appending right', N'Always sorting after each insert only', N'Using Union-Find on indices',
         N'B', N'Three phases over an already sorted list.', N'MEDIUM', 4, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Only binary searching the middle', OPTIONB = N'Emitting non-overlapping left, merging overlap region, then appending right', OPTIONC = N'Always sorting after each insert only', OPTIOND = N'Using Union-Find on indices',
        CORRECTOPTION = N'B', EXPLANATION = N'Three phases over an already sorted list.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 4, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_INTERVALS AND QUESTIONTEXT = N'Insert Interval can be done in one pass by:';
END

/* ---- Topic 6: Stack ---- */
IF NOT EXISTS (SELECT 1 FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'STACK')
BEGIN
    INSERT INTO dbo.TOPIC_MASTER
        (PATHID, TOPICKEY, TOPICNAME, DESCRIPTION, DIFFICULTYTIER, DISPLAYORDER,
         PREREQUISITETOPICID, ESTIMATEDMINUTES, THEORYMARKDOWN, ISACTIVE)
    VALUES
        (@PATHID, N'STACK', N'Stack', N'LIFO structure for parsing and monotonic patterns: Valid Parentheses, Simplify Path, Min Stack, Evaluate Reverse Polish Notation, Basic Calculator.', N'INTERMEDIATE', 6,
         (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'INTERVALS'),
         75, N'# Stack

## Uses
- Matching delimiters (**Valid Parentheses**).
- Path normalization (**Simplify Path**).
- Postfix evaluation (**RPN**).
- Supporting O(1) min with an auxiliary stack (**Min Stack**).
- Expression parsing (**Basic Calculator**) with sign/stack frames.

## Monotonic stack (related Top 150)
Daily Temperatures / next greater: maintain increasing/decreasing indices so each element is pushed/popped once → O(n).

## Invariants
Top of stack is the nearest unresolved opener / candidate.', 1);
END
ELSE
BEGIN
    UPDATE dbo.TOPIC_MASTER
    SET TOPICNAME = N'Stack',
        DESCRIPTION = N'LIFO structure for parsing and monotonic patterns: Valid Parentheses, Simplify Path, Min Stack, Evaluate Reverse Polish Notation, Basic Calculator.',
        DIFFICULTYTIER = N'INTERMEDIATE',
        DISPLAYORDER = 6,
        PREREQUISITETOPICID = (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'INTERVALS'),
        ESTIMATEDMINUTES = 75,
        THEORYMARKDOWN = N'# Stack

## Uses
- Matching delimiters (**Valid Parentheses**).
- Path normalization (**Simplify Path**).
- Postfix evaluation (**RPN**).
- Supporting O(1) min with an auxiliary stack (**Min Stack**).
- Expression parsing (**Basic Calculator**) with sign/stack frames.

## Monotonic stack (related Top 150)
Daily Temperatures / next greater: maintain increasing/decreasing indices so each element is pushed/popped once → O(n).

## Invariants
Top of stack is the nearest unresolved opener / candidate.',
        ISACTIVE = 1,
        UPDATEDDATE = SYSUTCDATETIME()
    WHERE PATHID = @PATHID AND TOPICKEY = N'STACK';
END
SELECT @T_STACK = TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'STACK';

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_STACK AND EXTERNALURL = N'https://leetcode.com/problems/valid-parentheses/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_STACK, N'PROBLEM', N'Valid Parentheses', N'Stack of opening brackets.', N'https://leetcode.com/problems/valid-parentheses/', N'LEETCODE', N'EASY', 1, 15, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Valid Parentheses', SUMMARY = N'Stack of opening brackets.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 1, ESTIMATEDMINUTES = 15,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_STACK AND EXTERNALURL = N'https://leetcode.com/problems/valid-parentheses/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_STACK AND EXTERNALURL = N'https://leetcode.com/problems/simplify-path/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_STACK, N'PROBLEM', N'Simplify Path', N'Unix path with . and .. via stack.', N'https://leetcode.com/problems/simplify-path/', N'LEETCODE', N'MEDIUM', 2, 25, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Simplify Path', SUMMARY = N'Unix path with . and .. via stack.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 2, ESTIMATEDMINUTES = 25,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_STACK AND EXTERNALURL = N'https://leetcode.com/problems/simplify-path/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_STACK AND EXTERNALURL = N'https://leetcode.com/problems/min-stack/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_STACK, N'PROBLEM', N'Min Stack', N'Aux stack or encode mins.', N'https://leetcode.com/problems/min-stack/', N'LEETCODE', N'MEDIUM', 3, 25, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Min Stack', SUMMARY = N'Aux stack or encode mins.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 3, ESTIMATEDMINUTES = 25,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_STACK AND EXTERNALURL = N'https://leetcode.com/problems/min-stack/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_STACK AND EXTERNALURL = N'https://leetcode.com/problems/evaluate-reverse-polish-notation/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_STACK, N'PROBLEM', N'Evaluate Reverse Polish Notation', N'Stack operands; apply operators.', N'https://leetcode.com/problems/evaluate-reverse-polish-notation/', N'LEETCODE', N'MEDIUM', 4, 25, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Evaluate Reverse Polish Notation', SUMMARY = N'Stack operands; apply operators.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 4, ESTIMATEDMINUTES = 25,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_STACK AND EXTERNALURL = N'https://leetcode.com/problems/evaluate-reverse-polish-notation/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_STACK AND EXTERNALURL = N'https://leetcode.com/problems/basic-calculator/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_STACK, N'PROBLEM', N'Basic Calculator', N'Signs and parentheses with a stack.', N'https://leetcode.com/problems/basic-calculator/', N'LEETCODE', N'HARD', 5, 40, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Basic Calculator', SUMMARY = N'Signs and parentheses with a stack.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'HARD', DISPLAYORDER = 5, ESTIMATEDMINUTES = 40,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_STACK AND EXTERNALURL = N'https://leetcode.com/problems/basic-calculator/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_STACK AND CONTENTTYPE = N'THEORY' AND TITLE = N'Stack — Theory')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_STACK, N'THEORY', N'Stack — Theory', N'Interview-oriented theory for Stack (Top 150 patterns).', NULL, N'STREAKLY', N'MEDIUM', 0, 20, 1);
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_STACK AND DISPLAYORDER = 1 AND QUESTIONTEXT = N'Valid Parentheses fails immediately when:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_STACK AND QUESTIONTEXT = N'Valid Parentheses fails immediately when:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_STACK, NULL, N'Valid Parentheses fails immediately when:', N'You see a closing bracket that does not match stack top', N'The string length is even', N'There are only round brackets', N'ASCII order is not sorted',
         N'A', N'Also fail if stack nonempty at end.', N'EASY', 1, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'You see a closing bracket that does not match stack top', OPTIONB = N'The string length is even', OPTIONC = N'There are only round brackets', OPTIOND = N'ASCII order is not sorted',
        CORRECTOPTION = N'A', EXPLANATION = N'Also fail if stack nonempty at end.', DIFFICULTY = N'EASY',
        DISPLAYORDER = 1, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_STACK AND QUESTIONTEXT = N'Valid Parentheses fails immediately when:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_STACK AND DISPLAYORDER = 2 AND QUESTIONTEXT = N'Min Stack getMin in O(1) is achieved by:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_STACK AND QUESTIONTEXT = N'Min Stack getMin in O(1) is achieved by:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_STACK, NULL, N'Min Stack getMin in O(1) is achieved by:', N'Scanning the whole stack each call', N'Keeping a parallel structure of minima as elements are pushed', N'Sorting on every push', N'Hashing values only',
         N'B', N'Push current min alongside values (or store pairs).', N'MEDIUM', 2, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Scanning the whole stack each call', OPTIONB = N'Keeping a parallel structure of minima as elements are pushed', OPTIONC = N'Sorting on every push', OPTIOND = N'Hashing values only',
        CORRECTOPTION = N'B', EXPLANATION = N'Push current min alongside values (or store pairs).', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 2, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_STACK AND QUESTIONTEXT = N'Min Stack getMin in O(1) is achieved by:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_STACK AND DISPLAYORDER = 3 AND QUESTIONTEXT = N'RPN evaluation pushes numbers and on an operator:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_STACK AND QUESTIONTEXT = N'RPN evaluation pushes numbers and on an operator:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_STACK, NULL, N'RPN evaluation pushes numbers and on an operator:', N'Pushes the operator', N'Pops operands, applies operator, pushes result', N'Clears the stack', N'Converts to infix first',
         N'B', N'Classic postfix machine.', N'EASY', 3, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Pushes the operator', OPTIONB = N'Pops operands, applies operator, pushes result', OPTIONC = N'Clears the stack', OPTIOND = N'Converts to infix first',
        CORRECTOPTION = N'B', EXPLANATION = N'Classic postfix machine.', DIFFICULTY = N'EASY',
        DISPLAYORDER = 3, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_STACK AND QUESTIONTEXT = N'RPN evaluation pushes numbers and on an operator:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_STACK AND DISPLAYORDER = 4 AND QUESTIONTEXT = N'Simplify Path treats ''..'' by:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_STACK AND QUESTIONTEXT = N'Simplify Path treats ''..'' by:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_STACK, NULL, N'Simplify Path treats ''..'' by:', N'Appending ''..'' always', N'Popping one directory level if the stack is non-empty', N'Sorting segments', N'Ignoring all segments',
         N'B', N'''.'' is no-op; empty segments from ''//'' skipped.', N'MEDIUM', 4, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Appending ''..'' always', OPTIONB = N'Popping one directory level if the stack is non-empty', OPTIONC = N'Sorting segments', OPTIOND = N'Ignoring all segments',
        CORRECTOPTION = N'B', EXPLANATION = N'''.'' is no-op; empty segments from ''//'' skipped.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 4, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_STACK AND QUESTIONTEXT = N'Simplify Path treats ''..'' by:';
END

/* ---- Topic 7: Linked List ---- */
IF NOT EXISTS (SELECT 1 FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'LINKED_LIST')
BEGIN
    INSERT INTO dbo.TOPIC_MASTER
        (PATHID, TOPICKEY, TOPICNAME, DESCRIPTION, DIFFICULTYTIER, DISPLAYORDER,
         PREREQUISITETOPICID, ESTIMATEDMINUTES, THEORYMARKDOWN, ISACTIVE)
    VALUES
        (@PATHID, N'LINKED_LIST', N'Linked List', N'Pointer rewiring: reverse, merge, cycle detection, remove nth from end, rotate, partition, LRU Cache (design).', N'INTERMEDIATE', 7,
         (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'STACK'),
         85, N'# Linked List

## Toolkit
- **Dummy head** — simplifies insert/delete at head.
- **Fast/slow** — middle, cycle detect (**Linked List Cycle**), cycle start.
- **Reverse** — iterative three pointers or recursion.
- **Merge** — Merge Two Sorted Lists / merge step of sort list.
- **Two-pass / gap** — Remove Nth Node From End with lead pointer.

## LRU Cache (Top 150 Design)
Hash map + doubly linked list: O(1) move-to-front and eviction.

## Safety
Always null-check; draw before/after pointer diagrams in interviews.', 1);
END
ELSE
BEGIN
    UPDATE dbo.TOPIC_MASTER
    SET TOPICNAME = N'Linked List',
        DESCRIPTION = N'Pointer rewiring: reverse, merge, cycle detection, remove nth from end, rotate, partition, LRU Cache (design).',
        DIFFICULTYTIER = N'INTERMEDIATE',
        DISPLAYORDER = 7,
        PREREQUISITETOPICID = (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'STACK'),
        ESTIMATEDMINUTES = 85,
        THEORYMARKDOWN = N'# Linked List

## Toolkit
- **Dummy head** — simplifies insert/delete at head.
- **Fast/slow** — middle, cycle detect (**Linked List Cycle**), cycle start.
- **Reverse** — iterative three pointers or recursion.
- **Merge** — Merge Two Sorted Lists / merge step of sort list.
- **Two-pass / gap** — Remove Nth Node From End with lead pointer.

## LRU Cache (Top 150 Design)
Hash map + doubly linked list: O(1) move-to-front and eviction.

## Safety
Always null-check; draw before/after pointer diagrams in interviews.',
        ISACTIVE = 1,
        UPDATEDDATE = SYSUTCDATETIME()
    WHERE PATHID = @PATHID AND TOPICKEY = N'LINKED_LIST';
END
SELECT @T_LINKED_LIST = TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'LINKED_LIST';

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_LINKED_LIST AND EXTERNALURL = N'https://leetcode.com/problems/linked-list-cycle/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_LINKED_LIST, N'PROBLEM', N'Linked List Cycle', N'Floyd fast/slow pointers.', N'https://leetcode.com/problems/linked-list-cycle/', N'LEETCODE', N'EASY', 1, 20, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Linked List Cycle', SUMMARY = N'Floyd fast/slow pointers.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 1, ESTIMATEDMINUTES = 20,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_LINKED_LIST AND EXTERNALURL = N'https://leetcode.com/problems/linked-list-cycle/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_LINKED_LIST AND EXTERNALURL = N'https://leetcode.com/problems/add-two-numbers/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_LINKED_LIST, N'PROBLEM', N'Add Two Numbers', N'Digit-wise sum with carry.', N'https://leetcode.com/problems/add-two-numbers/', N'LEETCODE', N'MEDIUM', 2, 25, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Add Two Numbers', SUMMARY = N'Digit-wise sum with carry.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 2, ESTIMATEDMINUTES = 25,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_LINKED_LIST AND EXTERNALURL = N'https://leetcode.com/problems/add-two-numbers/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_LINKED_LIST AND EXTERNALURL = N'https://leetcode.com/problems/merge-two-sorted-lists/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_LINKED_LIST, N'PROBLEM', N'Merge Two Sorted Lists', N'Dummy head merge.', N'https://leetcode.com/problems/merge-two-sorted-lists/', N'LEETCODE', N'EASY', 3, 20, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Merge Two Sorted Lists', SUMMARY = N'Dummy head merge.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 3, ESTIMATEDMINUTES = 20,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_LINKED_LIST AND EXTERNALURL = N'https://leetcode.com/problems/merge-two-sorted-lists/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_LINKED_LIST AND EXTERNALURL = N'https://leetcode.com/problems/copy-list-with-random-pointer/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_LINKED_LIST, N'PROBLEM', N'Copy List with Random Pointer', N'Map or interleaving copy.', N'https://leetcode.com/problems/copy-list-with-random-pointer/', N'LEETCODE', N'MEDIUM', 4, 35, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Copy List with Random Pointer', SUMMARY = N'Map or interleaving copy.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 4, ESTIMATEDMINUTES = 35,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_LINKED_LIST AND EXTERNALURL = N'https://leetcode.com/problems/copy-list-with-random-pointer/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_LINKED_LIST AND EXTERNALURL = N'https://leetcode.com/problems/reverse-linked-list-ii/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_LINKED_LIST, N'PROBLEM', N'Reverse Linked List II', N'Reverse a sublist [left,right].', N'https://leetcode.com/problems/reverse-linked-list-ii/', N'LEETCODE', N'MEDIUM', 5, 30, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Reverse Linked List II', SUMMARY = N'Reverse a sublist [left,right].', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 5, ESTIMATEDMINUTES = 30,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_LINKED_LIST AND EXTERNALURL = N'https://leetcode.com/problems/reverse-linked-list-ii/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_LINKED_LIST AND EXTERNALURL = N'https://leetcode.com/problems/reverse-nodes-in-k-group/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_LINKED_LIST, N'PROBLEM', N'Reverse Nodes in k-Group', N'Reverse every k nodes.', N'https://leetcode.com/problems/reverse-nodes-in-k-group/', N'LEETCODE', N'HARD', 6, 40, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Reverse Nodes in k-Group', SUMMARY = N'Reverse every k nodes.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'HARD', DISPLAYORDER = 6, ESTIMATEDMINUTES = 40,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_LINKED_LIST AND EXTERNALURL = N'https://leetcode.com/problems/reverse-nodes-in-k-group/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_LINKED_LIST AND EXTERNALURL = N'https://leetcode.com/problems/remove-nth-node-from-end-of-list/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_LINKED_LIST, N'PROBLEM', N'Remove Nth Node From End of List', N'Lead pointer by n.', N'https://leetcode.com/problems/remove-nth-node-from-end-of-list/', N'LEETCODE', N'MEDIUM', 7, 25, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Remove Nth Node From End of List', SUMMARY = N'Lead pointer by n.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 7, ESTIMATEDMINUTES = 25,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_LINKED_LIST AND EXTERNALURL = N'https://leetcode.com/problems/remove-nth-node-from-end-of-list/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_LINKED_LIST AND EXTERNALURL = N'https://leetcode.com/problems/remove-duplicates-from-sorted-list-ii/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_LINKED_LIST, N'PROBLEM', N'Remove Duplicates from Sorted List II', N'Skip all nodes of duplicated values.', N'https://leetcode.com/problems/remove-duplicates-from-sorted-list-ii/', N'LEETCODE', N'MEDIUM', 8, 30, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Remove Duplicates from Sorted List II', SUMMARY = N'Skip all nodes of duplicated values.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 8, ESTIMATEDMINUTES = 30,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_LINKED_LIST AND EXTERNALURL = N'https://leetcode.com/problems/remove-duplicates-from-sorted-list-ii/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_LINKED_LIST AND EXTERNALURL = N'https://leetcode.com/problems/rotate-list/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_LINKED_LIST, N'PROBLEM', N'Rotate List', N'Connect ring; break at new head.', N'https://leetcode.com/problems/rotate-list/', N'LEETCODE', N'MEDIUM', 9, 25, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Rotate List', SUMMARY = N'Connect ring; break at new head.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 9, ESTIMATEDMINUTES = 25,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_LINKED_LIST AND EXTERNALURL = N'https://leetcode.com/problems/rotate-list/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_LINKED_LIST AND EXTERNALURL = N'https://leetcode.com/problems/partition-list/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_LINKED_LIST, N'PROBLEM', N'Partition List', N'Two lists <x and ≥x then join.', N'https://leetcode.com/problems/partition-list/', N'LEETCODE', N'MEDIUM', 10, 25, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Partition List', SUMMARY = N'Two lists <x and ≥x then join.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 10, ESTIMATEDMINUTES = 25,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_LINKED_LIST AND EXTERNALURL = N'https://leetcode.com/problems/partition-list/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_LINKED_LIST AND EXTERNALURL = N'https://leetcode.com/problems/lru-cache/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_LINKED_LIST, N'PROBLEM', N'LRU Cache', N'HashMap + doubly linked list design.', N'https://leetcode.com/problems/lru-cache/', N'LEETCODE', N'MEDIUM', 11, 40, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'LRU Cache', SUMMARY = N'HashMap + doubly linked list design.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 11, ESTIMATEDMINUTES = 40,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_LINKED_LIST AND EXTERNALURL = N'https://leetcode.com/problems/lru-cache/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_LINKED_LIST AND CONTENTTYPE = N'THEORY' AND TITLE = N'Linked List — Theory')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_LINKED_LIST, N'THEORY', N'Linked List — Theory', N'Interview-oriented theory for Linked List (Top 150 patterns).', NULL, N'STREAKLY', N'MEDIUM', 0, 20, 1);
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_LINKED_LIST AND DISPLAYORDER = 1 AND QUESTIONTEXT = N'Floyd’s cycle detection uses:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_LINKED_LIST AND QUESTIONTEXT = N'Floyd’s cycle detection uses:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_LINKED_LIST, NULL, N'Floyd’s cycle detection uses:', N'A hash set only', N'Fast pointer moving 2 steps and slow moving 1', N'Binary lifting', N'Morris traversal exclusively',
         N'B', N'They meet iff a cycle exists.', N'EASY', 1, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'A hash set only', OPTIONB = N'Fast pointer moving 2 steps and slow moving 1', OPTIONC = N'Binary lifting', OPTIOND = N'Morris traversal exclusively',
        CORRECTOPTION = N'B', EXPLANATION = N'They meet iff a cycle exists.', DIFFICULTY = N'EASY',
        DISPLAYORDER = 1, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_LINKED_LIST AND QUESTIONTEXT = N'Floyd’s cycle detection uses:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_LINKED_LIST AND DISPLAYORDER = 2 AND QUESTIONTEXT = N'Remove Nth From End in one pass uses a gap of n between pointers so that:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_LINKED_LIST AND QUESTIONTEXT = N'Remove Nth From End in one pass uses a gap of n between pointers so that:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_LINKED_LIST, NULL, N'Remove Nth From End in one pass uses a gap of n between pointers so that:', N'The lead reaches null when the follower is at the node before the target', N'Both start at the tail', N'The list must be doubly linked', N'n is always 1',
         N'A', N'Dummy head helps when deleting the original head.', N'MEDIUM', 2, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'The lead reaches null when the follower is at the node before the target', OPTIONB = N'Both start at the tail', OPTIONC = N'The list must be doubly linked', OPTIOND = N'n is always 1',
        CORRECTOPTION = N'A', EXPLANATION = N'Dummy head helps when deleting the original head.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 2, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_LINKED_LIST AND QUESTIONTEXT = N'Remove Nth From End in one pass uses a gap of n between pointers so that:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_LINKED_LIST AND DISPLAYORDER = 3 AND QUESTIONTEXT = N'LRU Cache needs a doubly linked list primarily to:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_LINKED_LIST AND QUESTIONTEXT = N'LRU Cache needs a doubly linked list primarily to:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_LINKED_LIST, NULL, N'LRU Cache needs a doubly linked list primarily to:', N'Sort keys alphabetically', N'Move a node to most-recent position and evict least-recent in O(1)', N'Compute GCD of capacities', N'Store only values without keys',
         N'B', N'Map gives O(1) node access; list orders recency.', N'MEDIUM', 3, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Sort keys alphabetically', OPTIONB = N'Move a node to most-recent position and evict least-recent in O(1)', OPTIONC = N'Compute GCD of capacities', OPTIOND = N'Store only values without keys',
        CORRECTOPTION = N'B', EXPLANATION = N'Map gives O(1) node access; list orders recency.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 3, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_LINKED_LIST AND QUESTIONTEXT = N'LRU Cache needs a doubly linked list primarily to:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_LINKED_LIST AND DISPLAYORDER = 4 AND QUESTIONTEXT = N'Merge Two Sorted Lists invariant:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_LINKED_LIST AND QUESTIONTEXT = N'Merge Two Sorted Lists invariant:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_LINKED_LIST, NULL, N'Merge Two Sorted Lists invariant:', N'Always append the larger head', N'Always append the smaller current head of the two lists', N'Randomly pick a head', N'Reverse both lists first',
         N'B', N'Identical to merge step in merge sort.', N'EASY', 4, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Always append the larger head', OPTIONB = N'Always append the smaller current head of the two lists', OPTIONC = N'Randomly pick a head', OPTIOND = N'Reverse both lists first',
        CORRECTOPTION = N'B', EXPLANATION = N'Identical to merge step in merge sort.', DIFFICULTY = N'EASY',
        DISPLAYORDER = 4, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_LINKED_LIST AND QUESTIONTEXT = N'Merge Two Sorted Lists invariant:';
END

/* ---- Topic 8: Binary Tree ---- */
IF NOT EXISTS (SELECT 1 FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'BINARY_TREE')
BEGIN
    INSERT INTO dbo.TOPIC_MASTER
        (PATHID, TOPICKEY, TOPICNAME, DESCRIPTION, DIFFICULTYTIER, DISPLAYORDER,
         PREREQUISITETOPICID, ESTIMATEDMINUTES, THEORYMARKDOWN, ISACTIVE)
    VALUES
        (@PATHID, N'BINARY_TREE', N'Binary Tree', N'DFS/BFS tree problems from Top 150: depth, same tree, invert, path sum, diameter, good nodes, LCA, flatten, max path sum.', N'INTERMEDIATE', 8,
         (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'LINKED_LIST'),
         100, N'# Binary Tree (General)

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
If root matches p or q, return root; combine left/right recursive results.', 1);
END
ELSE
BEGIN
    UPDATE dbo.TOPIC_MASTER
    SET TOPICNAME = N'Binary Tree',
        DESCRIPTION = N'DFS/BFS tree problems from Top 150: depth, same tree, invert, path sum, diameter, good nodes, LCA, flatten, max path sum.',
        DIFFICULTYTIER = N'INTERMEDIATE',
        DISPLAYORDER = 8,
        PREREQUISITETOPICID = (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'LINKED_LIST'),
        ESTIMATEDMINUTES = 100,
        THEORYMARKDOWN = N'# Binary Tree (General)

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
If root matches p or q, return root; combine left/right recursive results.',
        ISACTIVE = 1,
        UPDATEDDATE = SYSUTCDATETIME()
    WHERE PATHID = @PATHID AND TOPICKEY = N'BINARY_TREE';
END
SELECT @T_BINARY_TREE = TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'BINARY_TREE';

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/maximum-depth-of-binary-tree/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BINARY_TREE, N'PROBLEM', N'Maximum Depth of Binary Tree', N'DFS/BFS height.', N'https://leetcode.com/problems/maximum-depth-of-binary-tree/', N'LEETCODE', N'EASY', 1, 15, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Maximum Depth of Binary Tree', SUMMARY = N'DFS/BFS height.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 1, ESTIMATEDMINUTES = 15,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/maximum-depth-of-binary-tree/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/same-tree/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BINARY_TREE, N'PROBLEM', N'Same Tree', N'Structural and value equality.', N'https://leetcode.com/problems/same-tree/', N'LEETCODE', N'EASY', 2, 15, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Same Tree', SUMMARY = N'Structural and value equality.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 2, ESTIMATEDMINUTES = 15,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/same-tree/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/invert-binary-tree/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BINARY_TREE, N'PROBLEM', N'Invert Binary Tree', N'Swap children recursively.', N'https://leetcode.com/problems/invert-binary-tree/', N'LEETCODE', N'EASY', 3, 15, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Invert Binary Tree', SUMMARY = N'Swap children recursively.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 3, ESTIMATEDMINUTES = 15,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/invert-binary-tree/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/symmetric-tree/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BINARY_TREE, N'PROBLEM', N'Symmetric Tree', N'Mirror recursion / BFS pairs.', N'https://leetcode.com/problems/symmetric-tree/', N'LEETCODE', N'EASY', 4, 20, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Symmetric Tree', SUMMARY = N'Mirror recursion / BFS pairs.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 4, ESTIMATEDMINUTES = 20,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/symmetric-tree/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/construct-binary-tree-from-preorder-and-inorder-traversal/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BINARY_TREE, N'PROBLEM', N'Construct Binary Tree from Preorder and Inorder Traversal', N'Hash inorder indices; recurse.', N'https://leetcode.com/problems/construct-binary-tree-from-preorder-and-inorder-traversal/', N'LEETCODE', N'MEDIUM', 5, 35, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Construct Binary Tree from Preorder and Inorder Traversal', SUMMARY = N'Hash inorder indices; recurse.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 5, ESTIMATEDMINUTES = 35,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/construct-binary-tree-from-preorder-and-inorder-traversal/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/construct-binary-tree-from-inorder-and-postorder-traversal/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BINARY_TREE, N'PROBLEM', N'Construct Binary Tree from Inorder and Postorder Traversal', N'Root at postorder end.', N'https://leetcode.com/problems/construct-binary-tree-from-inorder-and-postorder-traversal/', N'LEETCODE', N'MEDIUM', 6, 35, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Construct Binary Tree from Inorder and Postorder Traversal', SUMMARY = N'Root at postorder end.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 6, ESTIMATEDMINUTES = 35,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/construct-binary-tree-from-inorder-and-postorder-traversal/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/populating-next-right-pointers-in-each-node-ii/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BINARY_TREE, N'PROBLEM', N'Populating Next Right Pointers in Each Node II', N'Level links without perfect tree assumption.', N'https://leetcode.com/problems/populating-next-right-pointers-in-each-node-ii/', N'LEETCODE', N'MEDIUM', 7, 35, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Populating Next Right Pointers in Each Node II', SUMMARY = N'Level links without perfect tree assumption.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 7, ESTIMATEDMINUTES = 35,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/populating-next-right-pointers-in-each-node-ii/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/flatten-binary-tree-to-linked-list/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BINARY_TREE, N'PROBLEM', N'Flatten Binary Tree to Linked List', N'Preorder flatten in-place.', N'https://leetcode.com/problems/flatten-binary-tree-to-linked-list/', N'LEETCODE', N'MEDIUM', 8, 30, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Flatten Binary Tree to Linked List', SUMMARY = N'Preorder flatten in-place.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 8, ESTIMATEDMINUTES = 30,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/flatten-binary-tree-to-linked-list/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/path-sum/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BINARY_TREE, N'PROBLEM', N'Path Sum', N'Root-to-leaf remaining sum.', N'https://leetcode.com/problems/path-sum/', N'LEETCODE', N'EASY', 9, 20, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Path Sum', SUMMARY = N'Root-to-leaf remaining sum.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 9, ESTIMATEDMINUTES = 20,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/path-sum/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/sum-root-to-leaf-numbers/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BINARY_TREE, N'PROBLEM', N'Sum Root to Leaf Numbers', N'Accumulate digit paths.', N'https://leetcode.com/problems/sum-root-to-leaf-numbers/', N'LEETCODE', N'MEDIUM', 10, 25, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Sum Root to Leaf Numbers', SUMMARY = N'Accumulate digit paths.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 10, ESTIMATEDMINUTES = 25,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/sum-root-to-leaf-numbers/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/binary-tree-maximum-path-sum/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BINARY_TREE, N'PROBLEM', N'Binary Tree Maximum Path Sum', N'Node-centered path DP.', N'https://leetcode.com/problems/binary-tree-maximum-path-sum/', N'LEETCODE', N'HARD', 11, 40, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Binary Tree Maximum Path Sum', SUMMARY = N'Node-centered path DP.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'HARD', DISPLAYORDER = 11, ESTIMATEDMINUTES = 40,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/binary-tree-maximum-path-sum/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/binary-tree-level-order-traversal/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BINARY_TREE, N'PROBLEM', N'Binary Tree Level Order Traversal', N'BFS by levels.', N'https://leetcode.com/problems/binary-tree-level-order-traversal/', N'LEETCODE', N'MEDIUM', 12, 20, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Binary Tree Level Order Traversal', SUMMARY = N'BFS by levels.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 12, ESTIMATEDMINUTES = 20,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/binary-tree-level-order-traversal/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/average-of-levels-in-binary-tree/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BINARY_TREE, N'PROBLEM', N'Average of Levels in Binary Tree', N'BFS averages.', N'https://leetcode.com/problems/average-of-levels-in-binary-tree/', N'LEETCODE', N'EASY', 13, 15, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Average of Levels in Binary Tree', SUMMARY = N'BFS averages.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 13, ESTIMATEDMINUTES = 15,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/average-of-levels-in-binary-tree/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/binary-tree-zigzag-level-order-traversal/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BINARY_TREE, N'PROBLEM', N'Binary Tree Zigzag Level Order Traversal', N'Alternate direction per level.', N'https://leetcode.com/problems/binary-tree-zigzag-level-order-traversal/', N'LEETCODE', N'MEDIUM', 14, 25, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Binary Tree Zigzag Level Order Traversal', SUMMARY = N'Alternate direction per level.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 14, ESTIMATEDMINUTES = 25,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/binary-tree-zigzag-level-order-traversal/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/minimum-absolute-difference-in-bst/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BINARY_TREE, N'PROBLEM', N'Minimum Absolute Difference in BST', N'Inorder adjacent diffs.', N'https://leetcode.com/problems/minimum-absolute-difference-in-bst/', N'LEETCODE', N'EASY', 15, 20, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Minimum Absolute Difference in BST', SUMMARY = N'Inorder adjacent diffs.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 15, ESTIMATEDMINUTES = 20,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/minimum-absolute-difference-in-bst/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/kth-smallest-element-in-a-bst/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BINARY_TREE, N'PROBLEM', N'Kth Smallest Element in a BST', N'Inorder count / Morris.', N'https://leetcode.com/problems/kth-smallest-element-in-a-bst/', N'LEETCODE', N'MEDIUM', 16, 25, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Kth Smallest Element in a BST', SUMMARY = N'Inorder count / Morris.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 16, ESTIMATEDMINUTES = 25,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/kth-smallest-element-in-a-bst/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/validate-binary-search-tree/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BINARY_TREE, N'PROBLEM', N'Validate Binary Search Tree', N'Bounds or inorder increasing.', N'https://leetcode.com/problems/validate-binary-search-tree/', N'LEETCODE', N'MEDIUM', 17, 25, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Validate Binary Search Tree', SUMMARY = N'Bounds or inorder increasing.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 17, ESTIMATEDMINUTES = 25,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/validate-binary-search-tree/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/lowest-common-ancestor-of-a-binary-tree/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BINARY_TREE, N'PROBLEM', N'Lowest Common Ancestor of a Binary Tree', N'Postorder combine sides.', N'https://leetcode.com/problems/lowest-common-ancestor-of-a-binary-tree/', N'LEETCODE', N'MEDIUM', 18, 30, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Lowest Common Ancestor of a Binary Tree', SUMMARY = N'Postorder combine sides.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 18, ESTIMATEDMINUTES = 30,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_TREE AND EXTERNALURL = N'https://leetcode.com/problems/lowest-common-ancestor-of-a-binary-tree/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BINARY_TREE AND CONTENTTYPE = N'THEORY' AND TITLE = N'Binary Tree — Theory')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BINARY_TREE, N'THEORY', N'Binary Tree — Theory', N'Interview-oriented theory for Binary Tree (Top 150 patterns).', NULL, N'STREAKLY', N'MEDIUM', 0, 20, 1);
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BINARY_TREE AND DISPLAYORDER = 1 AND QUESTIONTEXT = N'Maximum depth of a binary tree equals:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BINARY_TREE AND QUESTIONTEXT = N'Maximum depth of a binary tree equals:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_BINARY_TREE, NULL, N'Maximum depth of a binary tree equals:', N'Number of nodes', N'1 + max(depth(left), depth(right)) (null → 0)', N'Width of the last level', N'Inorder length',
         N'B', N'Standard recursive height definition.', N'EASY', 1, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Number of nodes', OPTIONB = N'1 + max(depth(left), depth(right)) (null → 0)', OPTIONC = N'Width of the last level', OPTIOND = N'Inorder length',
        CORRECTOPTION = N'B', EXPLANATION = N'Standard recursive height definition.', DIFFICULTY = N'EASY',
        DISPLAYORDER = 1, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_TREE AND QUESTIONTEXT = N'Maximum depth of a binary tree equals:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BINARY_TREE AND DISPLAYORDER = 2 AND QUESTIONTEXT = N'Validate BST must enforce:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BINARY_TREE AND QUESTIONTEXT = N'Validate BST must enforce:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_BINARY_TREE, NULL, N'Validate BST must enforce:', N'Only left < root and right > root locally without ranges', N'All keys in left subtree < root < all keys in right subtree (bounds)', N'Perfect balance', N'Heap order',
         N'B', N'Local checks miss transitive violations; pass (min,max) bounds.', N'MEDIUM', 2, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Only left < root and right > root locally without ranges', OPTIONB = N'All keys in left subtree < root < all keys in right subtree (bounds)', OPTIONC = N'Perfect balance', OPTIOND = N'Heap order',
        CORRECTOPTION = N'B', EXPLANATION = N'Local checks miss transitive violations; pass (min,max) bounds.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 2, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_TREE AND QUESTIONTEXT = N'Validate BST must enforce:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BINARY_TREE AND DISPLAYORDER = 3 AND QUESTIONTEXT = N'Level-order traversal uses:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BINARY_TREE AND QUESTIONTEXT = N'Level-order traversal uses:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_BINARY_TREE, NULL, N'Level-order traversal uses:', N'A stack exclusively', N'A queue (BFS)', N'Union-Find', N'Dijkstra',
         N'B', N'Process nodes level by level.', N'EASY', 3, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'A stack exclusively', OPTIONB = N'A queue (BFS)', OPTIONC = N'Union-Find', OPTIOND = N'Dijkstra',
        CORRECTOPTION = N'B', EXPLANATION = N'Process nodes level by level.', DIFFICULTY = N'EASY',
        DISPLAYORDER = 3, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_TREE AND QUESTIONTEXT = N'Level-order traversal uses:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BINARY_TREE AND DISPLAYORDER = 4 AND QUESTIONTEXT = N'Binary Tree Maximum Path Sum allows the path to:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BINARY_TREE AND QUESTIONTEXT = N'Binary Tree Maximum Path Sum allows the path to:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_BINARY_TREE, NULL, N'Binary Tree Maximum Path Sum allows the path to:', N'Only go root-to-leaf', N'Bend at a node using both children contributions (with careful gains)', N'Only use right children', N'Skip the root always',
         N'B', N'Global answer can bend; return value to parent uses at most one child gain.', N'HARD', 4, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Only go root-to-leaf', OPTIONB = N'Bend at a node using both children contributions (with careful gains)', OPTIONC = N'Only use right children', OPTIOND = N'Skip the root always',
        CORRECTOPTION = N'B', EXPLANATION = N'Global answer can bend; return value to parent uses at most one child gain.', DIFFICULTY = N'HARD',
        DISPLAYORDER = 4, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_TREE AND QUESTIONTEXT = N'Binary Tree Maximum Path Sum allows the path to:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BINARY_TREE AND DISPLAYORDER = 5 AND QUESTIONTEXT = N'Construct tree from preorder+inorder: the preorder first element is:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BINARY_TREE AND QUESTIONTEXT = N'Construct tree from preorder+inorder: the preorder first element is:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_BINARY_TREE, NULL, N'Construct tree from preorder+inorder: the preorder first element is:', N'Always a leaf', N'The subtree root; inorder split defines left/right sizes', N'The maximum value', N'Irrelevant',
         N'B', N'Hash inorder positions to get O(n) construction.', N'MEDIUM', 5, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Always a leaf', OPTIONB = N'The subtree root; inorder split defines left/right sizes', OPTIONC = N'The maximum value', OPTIOND = N'Irrelevant',
        CORRECTOPTION = N'B', EXPLANATION = N'Hash inorder positions to get O(n) construction.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 5, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_TREE AND QUESTIONTEXT = N'Construct tree from preorder+inorder: the preorder first element is:';
END

/* ---- Topic 9: Graphs ---- */
IF NOT EXISTS (SELECT 1 FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'GRAPH')
BEGIN
    INSERT INTO dbo.TOPIC_MASTER
        (PATHID, TOPICKEY, TOPICNAME, DESCRIPTION, DIFFICULTYTIER, DISPLAYORDER,
         PREREQUISITETOPICID, ESTIMATEDMINUTES, THEORYMARKDOWN, ISACTIVE)
    VALUES
        (@PATHID, N'GRAPH', N'Graphs', N'Adjacency, BFS/DFS, islands, cloning, courses (topo), snaking word search, and evaluate division from Top 150.', N'ADVANCED', 9,
         (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'BINARY_TREE'),
         95, N'# Graphs

## Representations
Adjacency list for sparse graphs; matrix for dense / grid.

## Algorithms in Top 150
- **Number of Islands** — DFS/BFS flood fill on grid.
- **Clone Graph** — hash old→new while DFS/BFS.
- **Course Schedule / II** — cycle detect / Kahn topological sort.
- **Surrounded Regions** — mark border-connected ''O''s then flip.
- **Word Ladder** — BFS on implicit word graph (shortest transformation).

## Topo sort tip
Indegree queue (Kahn) or DFS coloring (0/1/2) for cycles.

## Complexity
V nodes, E edges: BFS/DFS **O(V+E)**.', 1);
END
ELSE
BEGIN
    UPDATE dbo.TOPIC_MASTER
    SET TOPICNAME = N'Graphs',
        DESCRIPTION = N'Adjacency, BFS/DFS, islands, cloning, courses (topo), snaking word search, and evaluate division from Top 150.',
        DIFFICULTYTIER = N'ADVANCED',
        DISPLAYORDER = 9,
        PREREQUISITETOPICID = (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'BINARY_TREE'),
        ESTIMATEDMINUTES = 95,
        THEORYMARKDOWN = N'# Graphs

## Representations
Adjacency list for sparse graphs; matrix for dense / grid.

## Algorithms in Top 150
- **Number of Islands** — DFS/BFS flood fill on grid.
- **Clone Graph** — hash old→new while DFS/BFS.
- **Course Schedule / II** — cycle detect / Kahn topological sort.
- **Surrounded Regions** — mark border-connected ''O''s then flip.
- **Word Ladder** — BFS on implicit word graph (shortest transformation).

## Topo sort tip
Indegree queue (Kahn) or DFS coloring (0/1/2) for cycles.

## Complexity
V nodes, E edges: BFS/DFS **O(V+E)**.',
        ISACTIVE = 1,
        UPDATEDDATE = SYSUTCDATETIME()
    WHERE PATHID = @PATHID AND TOPICKEY = N'GRAPH';
END
SELECT @T_GRAPH = TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'GRAPH';

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_GRAPH AND EXTERNALURL = N'https://leetcode.com/problems/number-of-islands/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_GRAPH, N'PROBLEM', N'Number of Islands', N'DFS/BFS flood fill on grid.', N'https://leetcode.com/problems/number-of-islands/', N'LEETCODE', N'MEDIUM', 1, 25, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Number of Islands', SUMMARY = N'DFS/BFS flood fill on grid.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 1, ESTIMATEDMINUTES = 25,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_GRAPH AND EXTERNALURL = N'https://leetcode.com/problems/number-of-islands/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_GRAPH AND EXTERNALURL = N'https://leetcode.com/problems/surrounded-regions/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_GRAPH, N'PROBLEM', N'Surrounded Regions', N'Border DFS then flip.', N'https://leetcode.com/problems/surrounded-regions/', N'LEETCODE', N'MEDIUM', 2, 30, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Surrounded Regions', SUMMARY = N'Border DFS then flip.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 2, ESTIMATEDMINUTES = 30,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_GRAPH AND EXTERNALURL = N'https://leetcode.com/problems/surrounded-regions/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_GRAPH AND EXTERNALURL = N'https://leetcode.com/problems/clone-graph/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_GRAPH, N'PROBLEM', N'Clone Graph', N'Map + DFS/BFS copy.', N'https://leetcode.com/problems/clone-graph/', N'LEETCODE', N'MEDIUM', 3, 30, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Clone Graph', SUMMARY = N'Map + DFS/BFS copy.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 3, ESTIMATEDMINUTES = 30,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_GRAPH AND EXTERNALURL = N'https://leetcode.com/problems/clone-graph/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_GRAPH AND EXTERNALURL = N'https://leetcode.com/problems/evaluate-division/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_GRAPH, N'PROBLEM', N'Evaluate Division', N'Weighted graph / UF with ratios.', N'https://leetcode.com/problems/evaluate-division/', N'LEETCODE', N'MEDIUM', 4, 35, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Evaluate Division', SUMMARY = N'Weighted graph / UF with ratios.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 4, ESTIMATEDMINUTES = 35,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_GRAPH AND EXTERNALURL = N'https://leetcode.com/problems/evaluate-division/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_GRAPH AND EXTERNALURL = N'https://leetcode.com/problems/course-schedule/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_GRAPH, N'PROBLEM', N'Course Schedule', N'Detect cycle in directed graph.', N'https://leetcode.com/problems/course-schedule/', N'LEETCODE', N'MEDIUM', 5, 30, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Course Schedule', SUMMARY = N'Detect cycle in directed graph.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 5, ESTIMATEDMINUTES = 30,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_GRAPH AND EXTERNALURL = N'https://leetcode.com/problems/course-schedule/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_GRAPH AND EXTERNALURL = N'https://leetcode.com/problems/course-schedule-ii/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_GRAPH, N'PROBLEM', N'Course Schedule II', N'Return a valid topological order.', N'https://leetcode.com/problems/course-schedule-ii/', N'LEETCODE', N'MEDIUM', 6, 30, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Course Schedule II', SUMMARY = N'Return a valid topological order.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 6, ESTIMATEDMINUTES = 30,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_GRAPH AND EXTERNALURL = N'https://leetcode.com/problems/course-schedule-ii/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_GRAPH AND EXTERNALURL = N'https://leetcode.com/problems/snakes-and-ladders/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_GRAPH, N'PROBLEM', N'Snakes and Ladders', N'BFS on board graph.', N'https://leetcode.com/problems/snakes-and-ladders/', N'LEETCODE', N'MEDIUM', 7, 35, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Snakes and Ladders', SUMMARY = N'BFS on board graph.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 7, ESTIMATEDMINUTES = 35,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_GRAPH AND EXTERNALURL = N'https://leetcode.com/problems/snakes-and-ladders/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_GRAPH AND EXTERNALURL = N'https://leetcode.com/problems/minimum-genetic-mutation/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_GRAPH, N'PROBLEM', N'Minimum Genetic Mutation', N'BFS word mutations.', N'https://leetcode.com/problems/minimum-genetic-mutation/', N'LEETCODE', N'MEDIUM', 8, 30, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Minimum Genetic Mutation', SUMMARY = N'BFS word mutations.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 8, ESTIMATEDMINUTES = 30,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_GRAPH AND EXTERNALURL = N'https://leetcode.com/problems/minimum-genetic-mutation/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_GRAPH AND EXTERNALURL = N'https://leetcode.com/problems/word-ladder/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_GRAPH, N'PROBLEM', N'Word Ladder', N'Shortest transformation BFS.', N'https://leetcode.com/problems/word-ladder/', N'LEETCODE', N'HARD', 9, 40, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Word Ladder', SUMMARY = N'Shortest transformation BFS.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'HARD', DISPLAYORDER = 9, ESTIMATEDMINUTES = 40,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_GRAPH AND EXTERNALURL = N'https://leetcode.com/problems/word-ladder/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_GRAPH AND CONTENTTYPE = N'THEORY' AND TITLE = N'Graphs — Theory')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_GRAPH, N'THEORY', N'Graphs — Theory', N'Interview-oriented theory for Graphs (Top 150 patterns).', NULL, N'STREAKLY', N'MEDIUM', 0, 20, 1);
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_GRAPH AND DISPLAYORDER = 1 AND QUESTIONTEXT = N'Number of Islands counts components by:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_GRAPH AND QUESTIONTEXT = N'Number of Islands counts components by:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_GRAPH, NULL, N'Number of Islands counts components by:', N'Sorting all cells', N'Flood-filling each unvisited land cell and incrementing once per component', N'Union of all water cells', N'Dijkstra from (0,0)',
         N'B', N'Each DFS/BFS from a ''1'' marks one island.', N'EASY', 1, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Sorting all cells', OPTIONB = N'Flood-filling each unvisited land cell and incrementing once per component', OPTIONC = N'Union of all water cells', OPTIOND = N'Dijkstra from (0,0)',
        CORRECTOPTION = N'B', EXPLANATION = N'Each DFS/BFS from a ''1'' marks one island.', DIFFICULTY = N'EASY',
        DISPLAYORDER = 1, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_GRAPH AND QUESTIONTEXT = N'Number of Islands counts components by:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_GRAPH AND DISPLAYORDER = 2 AND QUESTIONTEXT = N'Course Schedule is impossible when the prerequisite graph has:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_GRAPH AND QUESTIONTEXT = N'Course Schedule is impossible when the prerequisite graph has:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_GRAPH, NULL, N'Course Schedule is impossible when the prerequisite graph has:', N'Any undirected edge', N'A directed cycle', N'More than 10 nodes', N'Multiple connected components',
         N'B', N'A cycle means circular prerequisites.', N'MEDIUM', 2, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Any undirected edge', OPTIONB = N'A directed cycle', OPTIONC = N'More than 10 nodes', OPTIOND = N'Multiple connected components',
        CORRECTOPTION = N'B', EXPLANATION = N'A cycle means circular prerequisites.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 2, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_GRAPH AND QUESTIONTEXT = N'Course Schedule is impossible when the prerequisite graph has:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_GRAPH AND DISPLAYORDER = 3 AND QUESTIONTEXT = N'Kahn’s algorithm for topo sort repeatedly:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_GRAPH AND QUESTIONTEXT = N'Kahn’s algorithm for topo sort repeatedly:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_GRAPH, NULL, N'Kahn’s algorithm for topo sort repeatedly:', N'Removes nodes with indegree 0', N'Removes nodes with highest degree', N'DFS only', N'Sorts edges by weight',
         N'A', N'If not all nodes processed, a cycle exists.', N'MEDIUM', 3, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Removes nodes with indegree 0', OPTIONB = N'Removes nodes with highest degree', OPTIONC = N'DFS only', OPTIOND = N'Sorts edges by weight',
        CORRECTOPTION = N'A', EXPLANATION = N'If not all nodes processed, a cycle exists.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 3, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_GRAPH AND QUESTIONTEXT = N'Kahn’s algorithm for topo sort repeatedly:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_GRAPH AND DISPLAYORDER = 4 AND QUESTIONTEXT = N'Word Ladder finds shortest transformation using:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_GRAPH AND QUESTIONTEXT = N'Word Ladder finds shortest transformation using:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_GRAPH, NULL, N'Word Ladder finds shortest transformation using:', N'DFS with random restarts', N'BFS on the implicit graph of one-letter mutations', N'Dijkstra with negative weights', N'Binary search on string length',
         N'B', N'Unweighted shortest path → BFS.', N'MEDIUM', 4, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'DFS with random restarts', OPTIONB = N'BFS on the implicit graph of one-letter mutations', OPTIONC = N'Dijkstra with negative weights', OPTIOND = N'Binary search on string length',
        CORRECTOPTION = N'B', EXPLANATION = N'Unweighted shortest path → BFS.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 4, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_GRAPH AND QUESTIONTEXT = N'Word Ladder finds shortest transformation using:';
END

/* ---- Topic 10: Trie ---- */
IF NOT EXISTS (SELECT 1 FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'TRIE')
BEGIN
    INSERT INTO dbo.TOPIC_MASTER
        (PATHID, TOPICKEY, TOPICNAME, DESCRIPTION, DIFFICULTYTIER, DISPLAYORDER,
         PREREQUISITETOPICID, ESTIMATEDMINUTES, THEORYMARKDOWN, ISACTIVE)
    VALUES
        (@PATHID, N'TRIE', N'Trie', N'Prefix trees for Implement Trie and word search / design add-and-search from Top 150.', N'ADVANCED', 10,
         (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'GRAPH'),
         55, N'# Trie (Prefix Tree)

## Structure
Each edge is a character; node flags `isEnd`. Optional children array[26] or hash map.

## Operations
- Insert / Search / StartsWith — O(L) in word length.
- **Design Add and Search Words** — DFS on ''.'' wildcards.
- **Word Search II** — backtracking on board pruned by trie (and delete leaves for speed).

## Why interviews love it
Shows pointer/structure design and pruning intuition.', 1);
END
ELSE
BEGIN
    UPDATE dbo.TOPIC_MASTER
    SET TOPICNAME = N'Trie',
        DESCRIPTION = N'Prefix trees for Implement Trie and word search / design add-and-search from Top 150.',
        DIFFICULTYTIER = N'ADVANCED',
        DISPLAYORDER = 10,
        PREREQUISITETOPICID = (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'GRAPH'),
        ESTIMATEDMINUTES = 55,
        THEORYMARKDOWN = N'# Trie (Prefix Tree)

## Structure
Each edge is a character; node flags `isEnd`. Optional children array[26] or hash map.

## Operations
- Insert / Search / StartsWith — O(L) in word length.
- **Design Add and Search Words** — DFS on ''.'' wildcards.
- **Word Search II** — backtracking on board pruned by trie (and delete leaves for speed).

## Why interviews love it
Shows pointer/structure design and pruning intuition.',
        ISACTIVE = 1,
        UPDATEDDATE = SYSUTCDATETIME()
    WHERE PATHID = @PATHID AND TOPICKEY = N'TRIE';
END
SELECT @T_TRIE = TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'TRIE';

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_TRIE AND EXTERNALURL = N'https://leetcode.com/problems/implement-trie-prefix-tree/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_TRIE, N'PROBLEM', N'Implement Trie (Prefix Tree)', N'insert / search / startsWith.', N'https://leetcode.com/problems/implement-trie-prefix-tree/', N'LEETCODE', N'MEDIUM', 1, 30, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Implement Trie (Prefix Tree)', SUMMARY = N'insert / search / startsWith.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 1, ESTIMATEDMINUTES = 30,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_TRIE AND EXTERNALURL = N'https://leetcode.com/problems/implement-trie-prefix-tree/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_TRIE AND EXTERNALURL = N'https://leetcode.com/problems/design-add-and-search-words-data-structure/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_TRIE, N'PROBLEM', N'Design Add and Search Words Data Structure', N'Wildcard ''.'' via DFS.', N'https://leetcode.com/problems/design-add-and-search-words-data-structure/', N'LEETCODE', N'MEDIUM', 2, 35, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Design Add and Search Words Data Structure', SUMMARY = N'Wildcard ''.'' via DFS.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 2, ESTIMATEDMINUTES = 35,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_TRIE AND EXTERNALURL = N'https://leetcode.com/problems/design-add-and-search-words-data-structure/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_TRIE AND EXTERNALURL = N'https://leetcode.com/problems/word-search-ii/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_TRIE, N'PROBLEM', N'Word Search II', N'Board DFS pruned by trie.', N'https://leetcode.com/problems/word-search-ii/', N'LEETCODE', N'HARD', 3, 45, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Word Search II', SUMMARY = N'Board DFS pruned by trie.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'HARD', DISPLAYORDER = 3, ESTIMATEDMINUTES = 45,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_TRIE AND EXTERNALURL = N'https://leetcode.com/problems/word-search-ii/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_TRIE AND CONTENTTYPE = N'THEORY' AND TITLE = N'Trie — Theory')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_TRIE, N'THEORY', N'Trie — Theory', N'Interview-oriented theory for Trie (Top 150 patterns).', NULL, N'STREAKLY', N'MEDIUM', 0, 20, 1);
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_TRIE AND DISPLAYORDER = 1 AND QUESTIONTEXT = N'Trie startsWith is efficient because:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_TRIE AND QUESTIONTEXT = N'Trie startsWith is efficient because:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_TRIE, NULL, N'Trie startsWith is efficient because:', N'It sorts all words first', N'It walks only the prefix path of length L', N'It uses binary search on suffixes', N'It hashes the entire dictionary each call',
         N'B', N'O(L) independent of dictionary size (for fixed alphabet).', N'EASY', 1, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'It sorts all words first', OPTIONB = N'It walks only the prefix path of length L', OPTIONC = N'It uses binary search on suffixes', OPTIOND = N'It hashes the entire dictionary each call',
        CORRECTOPTION = N'B', EXPLANATION = N'O(L) independent of dictionary size (for fixed alphabet).', DIFFICULTY = N'EASY',
        DISPLAYORDER = 1, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_TRIE AND QUESTIONTEXT = N'Trie startsWith is efficient because:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_TRIE AND DISPLAYORDER = 2 AND QUESTIONTEXT = N'In Word Search II, a trie helps by:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_TRIE AND QUESTIONTEXT = N'In Word Search II, a trie helps by:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_TRIE, NULL, N'In Word Search II, a trie helps by:', N'Replacing the board', N'Pruning DFS paths that cannot match any remaining word', N'Sorting the board rows', N'Guaranteeing O(1) DFS',
         N'B', N'Only follow edges that exist in the trie.', N'HARD', 2, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Replacing the board', OPTIONB = N'Pruning DFS paths that cannot match any remaining word', OPTIONC = N'Sorting the board rows', OPTIOND = N'Guaranteeing O(1) DFS',
        CORRECTOPTION = N'B', EXPLANATION = N'Only follow edges that exist in the trie.', DIFFICULTY = N'HARD',
        DISPLAYORDER = 2, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_TRIE AND QUESTIONTEXT = N'In Word Search II, a trie helps by:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_TRIE AND DISPLAYORDER = 3 AND QUESTIONTEXT = N'Search with ''.'' in a trie requires:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_TRIE AND QUESTIONTEXT = N'Search with ''.'' in a trie requires:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_TRIE, NULL, N'Search with ''.'' in a trie requires:', N'Only following one child always', N'Branching DFS over all children at that position', N'Converting to a suffix array', N'Ignoring the rest of the pattern',
         N'B', N'Wildcard matches any character edge.', N'MEDIUM', 3, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Only following one child always', OPTIONB = N'Branching DFS over all children at that position', OPTIONC = N'Converting to a suffix array', OPTIOND = N'Ignoring the rest of the pattern',
        CORRECTOPTION = N'B', EXPLANATION = N'Wildcard matches any character edge.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 3, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_TRIE AND QUESTIONTEXT = N'Search with ''.'' in a trie requires:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_TRIE AND DISPLAYORDER = 4 AND QUESTIONTEXT = N'A trie node typically stores:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_TRIE AND QUESTIONTEXT = N'A trie node typically stores:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_TRIE, NULL, N'A trie node typically stores:', N'Only the full word string', N'Children map/array and an end-of-word flag', N'A priority queue', N'Graph edge weights',
         N'B', N'Minimal fields for insert/search/prefix.', N'EASY', 4, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Only the full word string', OPTIONB = N'Children map/array and an end-of-word flag', OPTIONC = N'A priority queue', OPTIOND = N'Graph edge weights',
        CORRECTOPTION = N'B', EXPLANATION = N'Minimal fields for insert/search/prefix.', DIFFICULTY = N'EASY',
        DISPLAYORDER = 4, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_TRIE AND QUESTIONTEXT = N'A trie node typically stores:';
END

/* ---- Topic 11: Backtracking ---- */
IF NOT EXISTS (SELECT 1 FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'BACKTRACKING')
BEGIN
    INSERT INTO dbo.TOPIC_MASTER
        (PATHID, TOPICKEY, TOPICNAME, DESCRIPTION, DIFFICULTYTIER, DISPLAYORDER,
         PREREQUISITETOPICID, ESTIMATEDMINUTES, THEORYMARKDOWN, ISACTIVE)
    VALUES
        (@PATHID, N'BACKTRACKING', N'Backtracking', N'Explore/build/retract: Letter Combinations, Combinations, Permutations, Combination Sum, N-Queens, Word Search, Generate Parentheses.', N'ADVANCED', 11,
         (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'TRIE'),
         80, N'# Backtracking

## Template
```
def dfs(path, state):
  if goal: record(path); return
  for choice in options:
    if invalid(choice): continue
    apply(choice); dfs(...); undo(choice)
```

## Top 150 themes
- **Combinations / Permutations** — index start vs used[] array.
- **Combination Sum** — reuse allowed → pass same `i`; unlimited candidates sorted for prune.
- **N-Queens** — column/diag bitsets.
- **Word Search** — mark visited cell; four directions.
- **Generate Parentheses** — track open/close counts.

## Pruning
Sort + break when candidate > remain; bitmasks for queens.', 1);
END
ELSE
BEGIN
    UPDATE dbo.TOPIC_MASTER
    SET TOPICNAME = N'Backtracking',
        DESCRIPTION = N'Explore/build/retract: Letter Combinations, Combinations, Permutations, Combination Sum, N-Queens, Word Search, Generate Parentheses.',
        DIFFICULTYTIER = N'ADVANCED',
        DISPLAYORDER = 11,
        PREREQUISITETOPICID = (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'TRIE'),
        ESTIMATEDMINUTES = 80,
        THEORYMARKDOWN = N'# Backtracking

## Template
```
def dfs(path, state):
  if goal: record(path); return
  for choice in options:
    if invalid(choice): continue
    apply(choice); dfs(...); undo(choice)
```

## Top 150 themes
- **Combinations / Permutations** — index start vs used[] array.
- **Combination Sum** — reuse allowed → pass same `i`; unlimited candidates sorted for prune.
- **N-Queens** — column/diag bitsets.
- **Word Search** — mark visited cell; four directions.
- **Generate Parentheses** — track open/close counts.

## Pruning
Sort + break when candidate > remain; bitmasks for queens.',
        ISACTIVE = 1,
        UPDATEDDATE = SYSUTCDATETIME()
    WHERE PATHID = @PATHID AND TOPICKEY = N'BACKTRACKING';
END
SELECT @T_BACKTRACKING = TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'BACKTRACKING';

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BACKTRACKING AND EXTERNALURL = N'https://leetcode.com/problems/letter-combinations-of-a-phone-number/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BACKTRACKING, N'PROBLEM', N'Letter Combinations of a Phone Number', N'DFS over digit→letters map.', N'https://leetcode.com/problems/letter-combinations-of-a-phone-number/', N'LEETCODE', N'MEDIUM', 1, 25, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Letter Combinations of a Phone Number', SUMMARY = N'DFS over digit→letters map.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 1, ESTIMATEDMINUTES = 25,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BACKTRACKING AND EXTERNALURL = N'https://leetcode.com/problems/letter-combinations-of-a-phone-number/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BACKTRACKING AND EXTERNALURL = N'https://leetcode.com/problems/combinations/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BACKTRACKING, N'PROBLEM', N'Combinations', N'Choose k numbers from 1..n.', N'https://leetcode.com/problems/combinations/', N'LEETCODE', N'MEDIUM', 2, 25, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Combinations', SUMMARY = N'Choose k numbers from 1..n.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 2, ESTIMATEDMINUTES = 25,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BACKTRACKING AND EXTERNALURL = N'https://leetcode.com/problems/combinations/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BACKTRACKING AND EXTERNALURL = N'https://leetcode.com/problems/permutations/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BACKTRACKING, N'PROBLEM', N'Permutations', N'Used[] or swap-based generation.', N'https://leetcode.com/problems/permutations/', N'LEETCODE', N'MEDIUM', 3, 25, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Permutations', SUMMARY = N'Used[] or swap-based generation.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 3, ESTIMATEDMINUTES = 25,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BACKTRACKING AND EXTERNALURL = N'https://leetcode.com/problems/permutations/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BACKTRACKING AND EXTERNALURL = N'https://leetcode.com/problems/combination-sum/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BACKTRACKING, N'PROBLEM', N'Combination Sum', N'Reuse candidates; target remainder.', N'https://leetcode.com/problems/combination-sum/', N'LEETCODE', N'MEDIUM', 4, 30, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Combination Sum', SUMMARY = N'Reuse candidates; target remainder.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 4, ESTIMATEDMINUTES = 30,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BACKTRACKING AND EXTERNALURL = N'https://leetcode.com/problems/combination-sum/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BACKTRACKING AND EXTERNALURL = N'https://leetcode.com/problems/n-queens-ii/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BACKTRACKING, N'PROBLEM', N'N-Queens II', N'Count solutions with diag constraints.', N'https://leetcode.com/problems/n-queens-ii/', N'LEETCODE', N'HARD', 5, 35, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'N-Queens II', SUMMARY = N'Count solutions with diag constraints.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'HARD', DISPLAYORDER = 5, ESTIMATEDMINUTES = 35,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BACKTRACKING AND EXTERNALURL = N'https://leetcode.com/problems/n-queens-ii/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BACKTRACKING AND EXTERNALURL = N'https://leetcode.com/problems/generate-parentheses/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BACKTRACKING, N'PROBLEM', N'Generate Parentheses', N'Balance open/close counters.', N'https://leetcode.com/problems/generate-parentheses/', N'LEETCODE', N'MEDIUM', 6, 25, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Generate Parentheses', SUMMARY = N'Balance open/close counters.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 6, ESTIMATEDMINUTES = 25,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BACKTRACKING AND EXTERNALURL = N'https://leetcode.com/problems/generate-parentheses/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BACKTRACKING AND EXTERNALURL = N'https://leetcode.com/problems/word-search/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BACKTRACKING, N'PROBLEM', N'Word Search', N'Board DFS with visit marks.', N'https://leetcode.com/problems/word-search/', N'LEETCODE', N'MEDIUM', 7, 30, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Word Search', SUMMARY = N'Board DFS with visit marks.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 7, ESTIMATEDMINUTES = 30,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BACKTRACKING AND EXTERNALURL = N'https://leetcode.com/problems/word-search/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BACKTRACKING AND CONTENTTYPE = N'THEORY' AND TITLE = N'Backtracking — Theory')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BACKTRACKING, N'THEORY', N'Backtracking — Theory', N'Interview-oriented theory for Backtracking (Top 150 patterns).', NULL, N'STREAKLY', N'MEDIUM', 0, 20, 1);
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BACKTRACKING AND DISPLAYORDER = 1 AND QUESTIONTEXT = N'Backtracking differs from plain recursion mainly by:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BACKTRACKING AND QUESTIONTEXT = N'Backtracking differs from plain recursion mainly by:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_BACKTRACKING, NULL, N'Backtracking differs from plain recursion mainly by:', N'Never returning', N'Undoing choices after exploring a branch', N'Using only BFS', N'Forbidding pruning',
         N'B', N'Apply → explore → revert keeps state consistent.', N'EASY', 1, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Never returning', OPTIONB = N'Undoing choices after exploring a branch', OPTIONC = N'Using only BFS', OPTIOND = N'Forbidding pruning',
        CORRECTOPTION = N'B', EXPLANATION = N'Apply → explore → revert keeps state consistent.', DIFFICULTY = N'EASY',
        DISPLAYORDER = 1, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BACKTRACKING AND QUESTIONTEXT = N'Backtracking differs from plain recursion mainly by:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BACKTRACKING AND DISPLAYORDER = 2 AND QUESTIONTEXT = N'Combination Sum allows reusing a number by:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BACKTRACKING AND QUESTIONTEXT = N'Combination Sum allows reusing a number by:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_BACKTRACKING, NULL, N'Combination Sum allows reusing a number by:', N'Passing i+1 always', N'Passing the same index i after choosing candidates[i]', N'Sorting descending only', N'Using a queue',
         N'B', N'Permutations of the same multiset are avoided by nondecreasing index order.', N'MEDIUM', 2, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Passing i+1 always', OPTIONB = N'Passing the same index i after choosing candidates[i]', OPTIONC = N'Sorting descending only', OPTIOND = N'Using a queue',
        CORRECTOPTION = N'B', EXPLANATION = N'Permutations of the same multiset are avoided by nondecreasing index order.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 2, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BACKTRACKING AND QUESTIONTEXT = N'Combination Sum allows reusing a number by:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BACKTRACKING AND DISPLAYORDER = 3 AND QUESTIONTEXT = N'N-Queens column/diag tracking prevents:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BACKTRACKING AND QUESTIONTEXT = N'N-Queens column/diag tracking prevents:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_BACKTRACKING, NULL, N'N-Queens column/diag tracking prevents:', N'Duplicate board sizes', N'Attacking placements on the same column or diagonal', N'Odd n', N'Recursion depth > 2',
         N'B', N'Bitsets or boolean arrays mark attacked lines.', N'MEDIUM', 3, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Duplicate board sizes', OPTIONB = N'Attacking placements on the same column or diagonal', OPTIONC = N'Odd n', OPTIOND = N'Recursion depth > 2',
        CORRECTOPTION = N'B', EXPLANATION = N'Bitsets or boolean arrays mark attacked lines.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 3, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BACKTRACKING AND QUESTIONTEXT = N'N-Queens column/diag tracking prevents:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BACKTRACKING AND DISPLAYORDER = 4 AND QUESTIONTEXT = N'Generate Parentheses prunes when:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BACKTRACKING AND QUESTIONTEXT = N'Generate Parentheses prunes when:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_BACKTRACKING, NULL, N'Generate Parentheses prunes when:', N'close > open or open > n', N'open == close always', N'n is even', N'The string is empty',
         N'A', N'Never place more closes than opens; never exceed n opens.', N'MEDIUM', 4, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'close > open or open > n', OPTIONB = N'open == close always', OPTIONC = N'n is even', OPTIOND = N'The string is empty',
        CORRECTOPTION = N'A', EXPLANATION = N'Never place more closes than opens; never exceed n opens.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 4, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BACKTRACKING AND QUESTIONTEXT = N'Generate Parentheses prunes when:';
END

/* ---- Topic 12: Binary Search ---- */
IF NOT EXISTS (SELECT 1 FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'BINARY_SEARCH')
BEGIN
    INSERT INTO dbo.TOPIC_MASTER
        (PATHID, TOPICKEY, TOPICNAME, DESCRIPTION, DIFFICULTYTIER, DISPLAYORDER,
         PREREQUISITETOPICID, ESTIMATEDMINUTES, THEORYMARKDOWN, ISACTIVE)
    VALUES
        (@PATHID, N'BINARY_SEARCH', N'Binary Search', N'Search on sorted data and on answer space: classic Binary Search, search rotated array, find peak, median of two sorted arrays, and koko/split array style decisions.', N'INTERMEDIATE', 12,
         (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'BACKTRACKING'),
         85, N'# Binary Search

## On indices
Maintain `lo..hi` with a clear predicate: find target, lower_bound, first true.

## On answer space (Top 150 style)
- **Koko Eating Bananas** — binary search speed; feasibility = hours ≤ h.
- **Split Array Largest Sum** — minimize largest partition sum.
- **Median of Two Sorted Arrays** — partition binary search (hard).

## Rotated sorted array
Identify sorted half; decide which half contains target.

## Template tip
Prefer `while (lo < hi)` with `mid = lo + (hi-lo)/2` and move `lo = mid+1` or `hi = mid` consistently.', 1);
END
ELSE
BEGIN
    UPDATE dbo.TOPIC_MASTER
    SET TOPICNAME = N'Binary Search',
        DESCRIPTION = N'Search on sorted data and on answer space: classic Binary Search, search rotated array, find peak, median of two sorted arrays, and koko/split array style decisions.',
        DIFFICULTYTIER = N'INTERMEDIATE',
        DISPLAYORDER = 12,
        PREREQUISITETOPICID = (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'BACKTRACKING'),
        ESTIMATEDMINUTES = 85,
        THEORYMARKDOWN = N'# Binary Search

## On indices
Maintain `lo..hi` with a clear predicate: find target, lower_bound, first true.

## On answer space (Top 150 style)
- **Koko Eating Bananas** — binary search speed; feasibility = hours ≤ h.
- **Split Array Largest Sum** — minimize largest partition sum.
- **Median of Two Sorted Arrays** — partition binary search (hard).

## Rotated sorted array
Identify sorted half; decide which half contains target.

## Template tip
Prefer `while (lo < hi)` with `mid = lo + (hi-lo)/2` and move `lo = mid+1` or `hi = mid` consistently.',
        ISACTIVE = 1,
        UPDATEDDATE = SYSUTCDATETIME()
    WHERE PATHID = @PATHID AND TOPICKEY = N'BINARY_SEARCH';
END
SELECT @T_BINARY_SEARCH = TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'BINARY_SEARCH';

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BINARY_SEARCH AND EXTERNALURL = N'https://leetcode.com/problems/search-insert-position/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BINARY_SEARCH, N'PROBLEM', N'Search Insert Position', N'Lower bound in sorted array.', N'https://leetcode.com/problems/search-insert-position/', N'LEETCODE', N'EASY', 1, 15, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Search Insert Position', SUMMARY = N'Lower bound in sorted array.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 1, ESTIMATEDMINUTES = 15,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_SEARCH AND EXTERNALURL = N'https://leetcode.com/problems/search-insert-position/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BINARY_SEARCH AND EXTERNALURL = N'https://leetcode.com/problems/search-a-2d-matrix/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BINARY_SEARCH, N'PROBLEM', N'Search a 2D Matrix', N'Treat matrix as virtual sorted array.', N'https://leetcode.com/problems/search-a-2d-matrix/', N'LEETCODE', N'MEDIUM', 2, 20, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Search a 2D Matrix', SUMMARY = N'Treat matrix as virtual sorted array.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 2, ESTIMATEDMINUTES = 20,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_SEARCH AND EXTERNALURL = N'https://leetcode.com/problems/search-a-2d-matrix/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BINARY_SEARCH AND EXTERNALURL = N'https://leetcode.com/problems/find-peak-element/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BINARY_SEARCH, N'PROBLEM', N'Find Peak Element', N'Binary search on slope.', N'https://leetcode.com/problems/find-peak-element/', N'LEETCODE', N'MEDIUM', 3, 25, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Find Peak Element', SUMMARY = N'Binary search on slope.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 3, ESTIMATEDMINUTES = 25,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_SEARCH AND EXTERNALURL = N'https://leetcode.com/problems/find-peak-element/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BINARY_SEARCH AND EXTERNALURL = N'https://leetcode.com/problems/search-in-rotated-sorted-array/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BINARY_SEARCH, N'PROBLEM', N'Search in Rotated Sorted Array', N'Identify sorted half each step.', N'https://leetcode.com/problems/search-in-rotated-sorted-array/', N'LEETCODE', N'MEDIUM', 4, 30, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Search in Rotated Sorted Array', SUMMARY = N'Identify sorted half each step.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 4, ESTIMATEDMINUTES = 30,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_SEARCH AND EXTERNALURL = N'https://leetcode.com/problems/search-in-rotated-sorted-array/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BINARY_SEARCH AND EXTERNALURL = N'https://leetcode.com/problems/find-first-and-last-position-of-element-in-sorted-array/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BINARY_SEARCH, N'PROBLEM', N'Find First and Last Position of Element in Sorted Array', N'Two lower/upper bounds.', N'https://leetcode.com/problems/find-first-and-last-position-of-element-in-sorted-array/', N'LEETCODE', N'MEDIUM', 5, 25, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Find First and Last Position of Element in Sorted Array', SUMMARY = N'Two lower/upper bounds.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 5, ESTIMATEDMINUTES = 25,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_SEARCH AND EXTERNALURL = N'https://leetcode.com/problems/find-first-and-last-position-of-element-in-sorted-array/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BINARY_SEARCH AND EXTERNALURL = N'https://leetcode.com/problems/find-minimum-in-rotated-sorted-array/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BINARY_SEARCH, N'PROBLEM', N'Find Minimum in Rotated Sorted Array', N'Binary search pivot.', N'https://leetcode.com/problems/find-minimum-in-rotated-sorted-array/', N'LEETCODE', N'MEDIUM', 6, 25, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Find Minimum in Rotated Sorted Array', SUMMARY = N'Binary search pivot.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 6, ESTIMATEDMINUTES = 25,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_SEARCH AND EXTERNALURL = N'https://leetcode.com/problems/find-minimum-in-rotated-sorted-array/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BINARY_SEARCH AND EXTERNALURL = N'https://leetcode.com/problems/median-of-two-sorted-arrays/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BINARY_SEARCH, N'PROBLEM', N'Median of Two Sorted Arrays', N'Partition binary search.', N'https://leetcode.com/problems/median-of-two-sorted-arrays/', N'LEETCODE', N'HARD', 7, 45, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Median of Two Sorted Arrays', SUMMARY = N'Partition binary search.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'HARD', DISPLAYORDER = 7, ESTIMATEDMINUTES = 45,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_SEARCH AND EXTERNALURL = N'https://leetcode.com/problems/median-of-two-sorted-arrays/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BINARY_SEARCH AND CONTENTTYPE = N'THEORY' AND TITLE = N'Binary Search — Theory')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BINARY_SEARCH, N'THEORY', N'Binary Search — Theory', N'Interview-oriented theory for Binary Search (Top 150 patterns).', NULL, N'STREAKLY', N'MEDIUM', 0, 20, 1);
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BINARY_SEARCH AND DISPLAYORDER = 1 AND QUESTIONTEXT = N'Binary search on answer space requires:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BINARY_SEARCH AND QUESTIONTEXT = N'Binary search on answer space requires:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_BINARY_SEARCH, NULL, N'Binary search on answer space requires:', N'A monotonic feasibility predicate', N'The array to be unsorted', N'Graph edges', N'O(1) memory only always',
         N'A', N'If mid is feasible, try smaller (or larger) answers consistently.', N'MEDIUM', 1, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'A monotonic feasibility predicate', OPTIONB = N'The array to be unsorted', OPTIONC = N'Graph edges', OPTIOND = N'O(1) memory only always',
        CORRECTOPTION = N'A', EXPLANATION = N'If mid is feasible, try smaller (or larger) answers consistently.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 1, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_SEARCH AND QUESTIONTEXT = N'Binary search on answer space requires:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BINARY_SEARCH AND DISPLAYORDER = 2 AND QUESTIONTEXT = N'In a rotated sorted array with distinct values, one half of [lo,hi] is always:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BINARY_SEARCH AND QUESTIONTEXT = N'In a rotated sorted array with distinct values, one half of [lo,hi] is always:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_BINARY_SEARCH, NULL, N'In a rotated sorted array with distinct values, one half of [lo,hi] is always:', N'Empty', N'Sorted', N'Bitonic with two peaks', N'All equal',
         N'B', N'Compare nums[lo], nums[mid], nums[hi] to see which side is sorted.', N'MEDIUM', 2, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Empty', OPTIONB = N'Sorted', OPTIONC = N'Bitonic with two peaks', OPTIOND = N'All equal',
        CORRECTOPTION = N'B', EXPLANATION = N'Compare nums[lo], nums[mid], nums[hi] to see which side is sorted.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 2, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_SEARCH AND QUESTIONTEXT = N'In a rotated sorted array with distinct values, one half of [lo,hi] is always:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BINARY_SEARCH AND DISPLAYORDER = 3 AND QUESTIONTEXT = N'Find Peak Element can binary search because:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BINARY_SEARCH AND QUESTIONTEXT = N'Find Peak Element can binary search because:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_BINARY_SEARCH, NULL, N'Find Peak Element can binary search because:', N'Any peak works; move toward a greater neighbor', N'The array is strictly increasing', N'n ≤ 2 always', N'Peaks are unique and at index 0',
         N'A', N'Moving uphill guarantees a peak exists in that direction.', N'MEDIUM', 3, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Any peak works; move toward a greater neighbor', OPTIONB = N'The array is strictly increasing', OPTIONC = N'n ≤ 2 always', OPTIOND = N'Peaks are unique and at index 0',
        CORRECTOPTION = N'A', EXPLANATION = N'Moving uphill guarantees a peak exists in that direction.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 3, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_SEARCH AND QUESTIONTEXT = N'Find Peak Element can binary search because:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BINARY_SEARCH AND DISPLAYORDER = 4 AND QUESTIONTEXT = N'Search Insert Position returns:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BINARY_SEARCH AND QUESTIONTEXT = N'Search Insert Position returns:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_BINARY_SEARCH, NULL, N'Search Insert Position returns:', N'Always 0', N'The lower_bound index where target should be', N'The upper_bound exclusive only for duplicates', N'A random index',
         N'B', N'Classic binary lower bound.', N'EASY', 4, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Always 0', OPTIONB = N'The lower_bound index where target should be', OPTIONC = N'The upper_bound exclusive only for duplicates', OPTIOND = N'A random index',
        CORRECTOPTION = N'B', EXPLANATION = N'Classic binary lower bound.', DIFFICULTY = N'EASY',
        DISPLAYORDER = 4, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BINARY_SEARCH AND QUESTIONTEXT = N'Search Insert Position returns:';
END

/* ---- Topic 13: Heap / Priority Queue ---- */
IF NOT EXISTS (SELECT 1 FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'HEAP')
BEGIN
    INSERT INTO dbo.TOPIC_MASTER
        (PATHID, TOPICKEY, TOPICNAME, DESCRIPTION, DIFFICULTYTIER, DISPLAYORDER,
         PREREQUISITETOPICID, ESTIMATEDMINUTES, THEORYMARKDOWN, ISACTIVE)
    VALUES
        (@PATHID, N'HEAP', N'Heap / Priority Queue', N'Top-K and merge patterns: Kth Largest Element, Find Median from Data Stream, Merge k Sorted Lists, IPO, and related Top 150 heap uses.', N'ADVANCED', 13,
         (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'BINARY_SEARCH'),
         70, N'# Heap / Priority Queue

## When to reach for a heap
- Running **top-k** in a stream.
- Always need current min/max among candidates (**Merge k Sorted Lists**).
- Two-heap median (**Find Median from Data Stream**).

## Complexities
Insert/pop **O(log n)**; building heap **O(n)**.

## Tips
Min-heap of size k for kth largest; keep the larger half in a min-heap and smaller in max-heap for median.', 1);
END
ELSE
BEGIN
    UPDATE dbo.TOPIC_MASTER
    SET TOPICNAME = N'Heap / Priority Queue',
        DESCRIPTION = N'Top-K and merge patterns: Kth Largest Element, Find Median from Data Stream, Merge k Sorted Lists, IPO, and related Top 150 heap uses.',
        DIFFICULTYTIER = N'ADVANCED',
        DISPLAYORDER = 13,
        PREREQUISITETOPICID = (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'BINARY_SEARCH'),
        ESTIMATEDMINUTES = 70,
        THEORYMARKDOWN = N'# Heap / Priority Queue

## When to reach for a heap
- Running **top-k** in a stream.
- Always need current min/max among candidates (**Merge k Sorted Lists**).
- Two-heap median (**Find Median from Data Stream**).

## Complexities
Insert/pop **O(log n)**; building heap **O(n)**.

## Tips
Min-heap of size k for kth largest; keep the larger half in a min-heap and smaller in max-heap for median.',
        ISACTIVE = 1,
        UPDATEDDATE = SYSUTCDATETIME()
    WHERE PATHID = @PATHID AND TOPICKEY = N'HEAP';
END
SELECT @T_HEAP = TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'HEAP';

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_HEAP AND EXTERNALURL = N'https://leetcode.com/problems/kth-largest-element-in-an-array/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_HEAP, N'PROBLEM', N'Kth Largest Element in an Array', N'Min-heap of size k / Quickselect.', N'https://leetcode.com/problems/kth-largest-element-in-an-array/', N'LEETCODE', N'MEDIUM', 1, 25, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Kth Largest Element in an Array', SUMMARY = N'Min-heap of size k / Quickselect.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 1, ESTIMATEDMINUTES = 25,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_HEAP AND EXTERNALURL = N'https://leetcode.com/problems/kth-largest-element-in-an-array/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_HEAP AND EXTERNALURL = N'https://leetcode.com/problems/ipo/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_HEAP, N'PROBLEM', N'IPO', N'Capital vs profit heaps.', N'https://leetcode.com/problems/ipo/', N'LEETCODE', N'HARD', 2, 40, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'IPO', SUMMARY = N'Capital vs profit heaps.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'HARD', DISPLAYORDER = 2, ESTIMATEDMINUTES = 40,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_HEAP AND EXTERNALURL = N'https://leetcode.com/problems/ipo/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_HEAP AND EXTERNALURL = N'https://leetcode.com/problems/find-median-from-data-stream/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_HEAP, N'PROBLEM', N'Find Median from Data Stream', N'Two heaps balance.', N'https://leetcode.com/problems/find-median-from-data-stream/', N'LEETCODE', N'HARD', 3, 40, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Find Median from Data Stream', SUMMARY = N'Two heaps balance.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'HARD', DISPLAYORDER = 3, ESTIMATEDMINUTES = 40,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_HEAP AND EXTERNALURL = N'https://leetcode.com/problems/find-median-from-data-stream/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_HEAP AND EXTERNALURL = N'https://leetcode.com/problems/merge-k-sorted-lists/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_HEAP, N'PROBLEM', N'Merge k Sorted Lists', N'Min-heap of list heads.', N'https://leetcode.com/problems/merge-k-sorted-lists/', N'LEETCODE', N'HARD', 4, 35, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Merge k Sorted Lists', SUMMARY = N'Min-heap of list heads.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'HARD', DISPLAYORDER = 4, ESTIMATEDMINUTES = 35,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_HEAP AND EXTERNALURL = N'https://leetcode.com/problems/merge-k-sorted-lists/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_HEAP AND CONTENTTYPE = N'THEORY' AND TITLE = N'Heap / Priority Queue — Theory')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_HEAP, N'THEORY', N'Heap / Priority Queue — Theory', N'Interview-oriented theory for Heap / Priority Queue (Top 150 patterns).', NULL, N'STREAKLY', N'MEDIUM', 0, 20, 1);
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_HEAP AND DISPLAYORDER = 1 AND QUESTIONTEXT = N'Kth largest with a min-heap of size k keeps:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_HEAP AND QUESTIONTEXT = N'Kth largest with a min-heap of size k keeps:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_HEAP, NULL, N'Kth largest with a min-heap of size k keeps:', N'All n elements always', N'The k largest seen; heap top is the kth largest', N'Only the maximum', N'Sorted unique values',
         N'B', N'Pop when size > k so top is smallest of the k largest.', N'MEDIUM', 1, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'All n elements always', OPTIONB = N'The k largest seen; heap top is the kth largest', OPTIONC = N'Only the maximum', OPTIOND = N'Sorted unique values',
        CORRECTOPTION = N'B', EXPLANATION = N'Pop when size > k so top is smallest of the k largest.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 1, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_HEAP AND QUESTIONTEXT = N'Kth largest with a min-heap of size k keeps:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_HEAP AND DISPLAYORDER = 2 AND QUESTIONTEXT = N'Median of a stream with two heaps: max-heap stores:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_HEAP AND QUESTIONTEXT = N'Median of a stream with two heaps: max-heap stores:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_HEAP, NULL, N'Median of a stream with two heaps: max-heap stores:', N'The larger half of numbers', N'The smaller half of numbers', N'Only even indices', N'Graph nodes',
         N'B', N'max-heap for lower half; min-heap for upper half; balance sizes.', N'HARD', 2, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'The larger half of numbers', OPTIONB = N'The smaller half of numbers', OPTIONC = N'Only even indices', OPTIOND = N'Graph nodes',
        CORRECTOPTION = N'B', EXPLANATION = N'max-heap for lower half; min-heap for upper half; balance sizes.', DIFFICULTY = N'HARD',
        DISPLAYORDER = 2, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_HEAP AND QUESTIONTEXT = N'Median of a stream with two heaps: max-heap stores:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_HEAP AND DISPLAYORDER = 3 AND QUESTIONTEXT = N'Merge k Sorted Lists heap stores:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_HEAP AND QUESTIONTEXT = N'Merge k Sorted Lists heap stores:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_HEAP, NULL, N'Merge k Sorted Lists heap stores:', N'All nodes at once always', N'Current head of each list (up to k nodes)', N'Only the longest list', N'Random samples',
         N'B', N'Pop min, push that list’s next.', N'MEDIUM', 3, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'All nodes at once always', OPTIONB = N'Current head of each list (up to k nodes)', OPTIONC = N'Only the longest list', OPTIOND = N'Random samples',
        CORRECTOPTION = N'B', EXPLANATION = N'Pop min, push that list’s next.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 3, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_HEAP AND QUESTIONTEXT = N'Merge k Sorted Lists heap stores:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_HEAP AND DISPLAYORDER = 4 AND QUESTIONTEXT = N'Heap insert asymptotic cost is typically:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_HEAP AND QUESTIONTEXT = N'Heap insert asymptotic cost is typically:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_HEAP, NULL, N'Heap insert asymptotic cost is typically:', N'O(1)', N'O(log n)', N'O(n log n)', N'O(n²)',
         N'B', N'Bubble up along tree height.', N'EASY', 4, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'O(1)', OPTIONB = N'O(log n)', OPTIONC = N'O(n log n)', OPTIOND = N'O(n²)',
        CORRECTOPTION = N'B', EXPLANATION = N'Bubble up along tree height.', DIFFICULTY = N'EASY',
        DISPLAYORDER = 4, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_HEAP AND QUESTIONTEXT = N'Heap insert asymptotic cost is typically:';
END

/* ---- Topic 14: Greedy ---- */
IF NOT EXISTS (SELECT 1 FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'GREEDY')
BEGIN
    INSERT INTO dbo.TOPIC_MASTER
        (PATHID, TOPICKEY, TOPICNAME, DESCRIPTION, DIFFICULTYTIER, DISPLAYORDER,
         PREREQUISITETOPICID, ESTIMATEDMINUTES, THEORYMARKDOWN, ISACTIVE)
    VALUES
        (@PATHID, N'GREEDY', N'Greedy', N'Local optimal choices: Jump Game II, Candy, Gas Station (also arrays), and partition labels style reasoning overlapping Top 150 greedy items.', N'INTERMEDIATE', 14,
         (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'HEAP'),
         65, N'# Greedy

## Definition
Make the choice that looks best now; prove no better global strategy exists (exchange argument / staying ahead).

## Top 150 anchors
- **Jump Game II** — BFS-like windows of farthest reach per jump count.
- **Candy** — two-pass ratings to satisfy neighbor constraints.
- **Gas Station** — unique start when total ≥ 0; reset tank on negative prefix.

## Red flags
If local choice needs future knowledge that isn’t monotonic, consider DP.', 1);
END
ELSE
BEGIN
    UPDATE dbo.TOPIC_MASTER
    SET TOPICNAME = N'Greedy',
        DESCRIPTION = N'Local optimal choices: Jump Game II, Candy, Gas Station (also arrays), and partition labels style reasoning overlapping Top 150 greedy items.',
        DIFFICULTYTIER = N'INTERMEDIATE',
        DISPLAYORDER = 14,
        PREREQUISITETOPICID = (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'HEAP'),
        ESTIMATEDMINUTES = 65,
        THEORYMARKDOWN = N'# Greedy

## Definition
Make the choice that looks best now; prove no better global strategy exists (exchange argument / staying ahead).

## Top 150 anchors
- **Jump Game II** — BFS-like windows of farthest reach per jump count.
- **Candy** — two-pass ratings to satisfy neighbor constraints.
- **Gas Station** — unique start when total ≥ 0; reset tank on negative prefix.

## Red flags
If local choice needs future knowledge that isn’t monotonic, consider DP.',
        ISACTIVE = 1,
        UPDATEDDATE = SYSUTCDATETIME()
    WHERE PATHID = @PATHID AND TOPICKEY = N'GREEDY';
END
SELECT @T_GREEDY = TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'GREEDY';

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_GREEDY AND EXTERNALURL = N'https://leetcode.com/problems/jump-game-ii/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_GREEDY, N'PROBLEM', N'Jump Game II', N'Minimum jumps via reach windows.', N'https://leetcode.com/problems/jump-game-ii/', N'LEETCODE', N'MEDIUM', 1, 30, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Jump Game II', SUMMARY = N'Minimum jumps via reach windows.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 1, ESTIMATEDMINUTES = 30,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_GREEDY AND EXTERNALURL = N'https://leetcode.com/problems/jump-game-ii/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_GREEDY AND EXTERNALURL = N'https://leetcode.com/problems/candy/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_GREEDY, N'PROBLEM', N'Candy', N'Two-pass rating distribution.', N'https://leetcode.com/problems/candy/', N'LEETCODE', N'HARD', 2, 35, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Candy', SUMMARY = N'Two-pass rating distribution.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'HARD', DISPLAYORDER = 2, ESTIMATEDMINUTES = 35,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_GREEDY AND EXTERNALURL = N'https://leetcode.com/problems/candy/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_GREEDY AND EXTERNALURL = N'https://leetcode.com/problems/maximum-subarray/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_GREEDY, N'PROBLEM', N'Maximum Subarray', N'Kadane’s algorithm (greedy/DP).', N'https://leetcode.com/problems/maximum-subarray/', N'LEETCODE', N'MEDIUM', 3, 20, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Maximum Subarray', SUMMARY = N'Kadane’s algorithm (greedy/DP).', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 3, ESTIMATEDMINUTES = 20,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_GREEDY AND EXTERNALURL = N'https://leetcode.com/problems/maximum-subarray/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_GREEDY AND EXTERNALURL = N'https://leetcode.com/problems/maximum-sum-circular-subarray/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_GREEDY, N'PROBLEM', N'Maximum Sum Circular Subarray', N'Kadane + total−minSubarray.', N'https://leetcode.com/problems/maximum-sum-circular-subarray/', N'LEETCODE', N'MEDIUM', 4, 35, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Maximum Sum Circular Subarray', SUMMARY = N'Kadane + total−minSubarray.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 4, ESTIMATEDMINUTES = 35,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_GREEDY AND EXTERNALURL = N'https://leetcode.com/problems/maximum-sum-circular-subarray/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_GREEDY AND CONTENTTYPE = N'THEORY' AND TITLE = N'Greedy — Theory')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_GREEDY, N'THEORY', N'Greedy — Theory', N'Interview-oriented theory for Greedy (Top 150 patterns).', NULL, N'STREAKLY', N'MEDIUM', 0, 20, 1);
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_GREEDY AND DISPLAYORDER = 1 AND QUESTIONTEXT = N'Jump Game II increases jump count when:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_GREEDY AND QUESTIONTEXT = N'Jump Game II increases jump count when:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_GREEDY, NULL, N'Jump Game II increases jump count when:', N'i exceeds the end of the current reach window', N'nums[i] == 0', N'The array is sorted', N'n is odd',
         N'A', N'Each window is the farthest reachable with the current jump budget.', N'MEDIUM', 1, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'i exceeds the end of the current reach window', OPTIONB = N'nums[i] == 0', OPTIONC = N'The array is sorted', OPTIOND = N'n is odd',
        CORRECTOPTION = N'A', EXPLANATION = N'Each window is the farthest reachable with the current jump budget.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 1, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_GREEDY AND QUESTIONTEXT = N'Jump Game II increases jump count when:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_GREEDY AND DISPLAYORDER = 2 AND QUESTIONTEXT = N'Kadane’s algorithm tracks:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_GREEDY AND QUESTIONTEXT = N'Kadane’s algorithm tracks:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_GREEDY, NULL, N'Kadane’s algorithm tracks:', N'Global max of ending-here sums', N'Only prefix sums', N'Dijkstra distances', N'LIS length only',
         N'A', N'bestEndingHere = max(x, bestEndingHere + x).', N'EASY', 2, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Global max of ending-here sums', OPTIONB = N'Only prefix sums', OPTIONC = N'Dijkstra distances', OPTIOND = N'LIS length only',
        CORRECTOPTION = N'A', EXPLANATION = N'bestEndingHere = max(x, bestEndingHere + x).', DIFFICULTY = N'EASY',
        DISPLAYORDER = 2, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_GREEDY AND QUESTIONTEXT = N'Kadane’s algorithm tracks:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_GREEDY AND DISPLAYORDER = 3 AND QUESTIONTEXT = N'Candy two-pass ensures:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_GREEDY AND QUESTIONTEXT = N'Candy two-pass ensures:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_GREEDY, NULL, N'Candy two-pass ensures:', N'Random distribution', N'Both left and right neighbor inequalities are satisfied', N'Minimum is always 0', N'Heap order',
         N'B', N'Left-to-right then right-to-left take maxima of requirements.', N'HARD', 3, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Random distribution', OPTIONB = N'Both left and right neighbor inequalities are satisfied', OPTIONC = N'Minimum is always 0', OPTIOND = N'Heap order',
        CORRECTOPTION = N'B', EXPLANATION = N'Left-to-right then right-to-left take maxima of requirements.', DIFFICULTY = N'HARD',
        DISPLAYORDER = 3, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_GREEDY AND QUESTIONTEXT = N'Candy two-pass ensures:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_GREEDY AND DISPLAYORDER = 4 AND QUESTIONTEXT = N'Circular max subarray combines:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_GREEDY AND QUESTIONTEXT = N'Circular max subarray combines:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_GREEDY, NULL, N'Circular max subarray combines:', N'Standard Kadane and totalSum − minimum subarray sum', N'Only sorting', N'BFS', N'Trie paths',
         N'A', N'Wrap-around case equals total minus the worst middle segment.', N'MEDIUM', 4, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Standard Kadane and totalSum − minimum subarray sum', OPTIONB = N'Only sorting', OPTIONC = N'BFS', OPTIOND = N'Trie paths',
        CORRECTOPTION = N'A', EXPLANATION = N'Wrap-around case equals total minus the worst middle segment.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 4, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_GREEDY AND QUESTIONTEXT = N'Circular max subarray combines:';
END

/* ---- Topic 15: 1D Dynamic Programming ---- */
IF NOT EXISTS (SELECT 1 FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'DP_1D')
BEGIN
    INSERT INTO dbo.TOPIC_MASTER
        (PATHID, TOPICKEY, TOPICNAME, DESCRIPTION, DIFFICULTYTIER, DISPLAYORDER,
         PREREQUISITETOPICID, ESTIMATEDMINUTES, THEORYMARKDOWN, ISACTIVE)
    VALUES
        (@PATHID, N'DP_1D', N'1D Dynamic Programming', N'Linear DP from Top 150: Climbing Stairs, House Robber, Word Break, Coin Change, Longest Increasing Subsequence.', N'ADVANCED', 15,
         (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'GREEDY'),
         90, N'# 1D Dynamic Programming

## Mindset
Define `dp[i]` as an optimal answer for prefix/suffix `i`; relate to smaller indices.

## Top 150 catalogue
- **Climbing Stairs** — Fibonacci.
- **House Robber** — take/skip recurrence.
- **Word Break** — boolean DP with dictionary set.
- **Coin Change** — unbounded knapsack for min coins.
- **LIS** — O(n²) DP or O(n log n) tails binary search.

## Space
Many collapse to O(1) or O(W) rolling arrays.', 1);
END
ELSE
BEGIN
    UPDATE dbo.TOPIC_MASTER
    SET TOPICNAME = N'1D Dynamic Programming',
        DESCRIPTION = N'Linear DP from Top 150: Climbing Stairs, House Robber, Word Break, Coin Change, Longest Increasing Subsequence.',
        DIFFICULTYTIER = N'ADVANCED',
        DISPLAYORDER = 15,
        PREREQUISITETOPICID = (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'GREEDY'),
        ESTIMATEDMINUTES = 90,
        THEORYMARKDOWN = N'# 1D Dynamic Programming

## Mindset
Define `dp[i]` as an optimal answer for prefix/suffix `i`; relate to smaller indices.

## Top 150 catalogue
- **Climbing Stairs** — Fibonacci.
- **House Robber** — take/skip recurrence.
- **Word Break** — boolean DP with dictionary set.
- **Coin Change** — unbounded knapsack for min coins.
- **LIS** — O(n²) DP or O(n log n) tails binary search.

## Space
Many collapse to O(1) or O(W) rolling arrays.',
        ISACTIVE = 1,
        UPDATEDDATE = SYSUTCDATETIME()
    WHERE PATHID = @PATHID AND TOPICKEY = N'DP_1D';
END
SELECT @T_DP_1D = TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'DP_1D';

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_DP_1D AND EXTERNALURL = N'https://leetcode.com/problems/climbing-stairs/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_DP_1D, N'PROBLEM', N'Climbing Stairs', N'Ways = fibonacci.', N'https://leetcode.com/problems/climbing-stairs/', N'LEETCODE', N'EASY', 1, 15, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Climbing Stairs', SUMMARY = N'Ways = fibonacci.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 1, ESTIMATEDMINUTES = 15,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_DP_1D AND EXTERNALURL = N'https://leetcode.com/problems/climbing-stairs/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_DP_1D AND EXTERNALURL = N'https://leetcode.com/problems/house-robber/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_DP_1D, N'PROBLEM', N'House Robber', N'Rob or skip adjacent constraint.', N'https://leetcode.com/problems/house-robber/', N'LEETCODE', N'MEDIUM', 2, 20, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'House Robber', SUMMARY = N'Rob or skip adjacent constraint.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 2, ESTIMATEDMINUTES = 20,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_DP_1D AND EXTERNALURL = N'https://leetcode.com/problems/house-robber/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_DP_1D AND EXTERNALURL = N'https://leetcode.com/problems/word-break/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_DP_1D, N'PROBLEM', N'Word Break', N'DP reachability with dict words.', N'https://leetcode.com/problems/word-break/', N'LEETCODE', N'MEDIUM', 3, 30, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Word Break', SUMMARY = N'DP reachability with dict words.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 3, ESTIMATEDMINUTES = 30,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_DP_1D AND EXTERNALURL = N'https://leetcode.com/problems/word-break/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_DP_1D AND EXTERNALURL = N'https://leetcode.com/problems/coin-change/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_DP_1D, N'PROBLEM', N'Coin Change', N'Min coins unbounded knapsack.', N'https://leetcode.com/problems/coin-change/', N'LEETCODE', N'MEDIUM', 4, 30, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Coin Change', SUMMARY = N'Min coins unbounded knapsack.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 4, ESTIMATEDMINUTES = 30,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_DP_1D AND EXTERNALURL = N'https://leetcode.com/problems/coin-change/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_DP_1D AND EXTERNALURL = N'https://leetcode.com/problems/longest-increasing-subsequence/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_DP_1D, N'PROBLEM', N'Longest Increasing Subsequence', N'DP or patience sorting tails.', N'https://leetcode.com/problems/longest-increasing-subsequence/', N'LEETCODE', N'MEDIUM', 5, 35, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Longest Increasing Subsequence', SUMMARY = N'DP or patience sorting tails.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 5, ESTIMATEDMINUTES = 35,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_DP_1D AND EXTERNALURL = N'https://leetcode.com/problems/longest-increasing-subsequence/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_DP_1D AND CONTENTTYPE = N'THEORY' AND TITLE = N'1D Dynamic Programming — Theory')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_DP_1D, N'THEORY', N'1D Dynamic Programming — Theory', N'Interview-oriented theory for 1D Dynamic Programming (Top 150 patterns).', NULL, N'STREAKLY', N'MEDIUM', 0, 20, 1);
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_DP_1D AND DISPLAYORDER = 1 AND QUESTIONTEXT = N'House Robber recurrence is closest to:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_DP_1D AND QUESTIONTEXT = N'House Robber recurrence is closest to:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_DP_1D, NULL, N'House Robber recurrence is closest to:', N'dp[i] = max(dp[i-1], dp[i-2] + nums[i])', N'dp[i] = dp[i-1] + dp[i-2]', N'dp[i] = min(nums)', N'dp[i] = nums[i] * i',
         N'A', N'Skip current vs take current + best before previous.', N'EASY', 1, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'dp[i] = max(dp[i-1], dp[i-2] + nums[i])', OPTIONB = N'dp[i] = dp[i-1] + dp[i-2]', OPTIONC = N'dp[i] = min(nums)', OPTIOND = N'dp[i] = nums[i] * i',
        CORRECTOPTION = N'A', EXPLANATION = N'Skip current vs take current + best before previous.', DIFFICULTY = N'EASY',
        DISPLAYORDER = 1, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_DP_1D AND QUESTIONTEXT = N'House Robber recurrence is closest to:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_DP_1D AND DISPLAYORDER = 2 AND QUESTIONTEXT = N'Coin Change (min coins) initializes dp[0] to:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_DP_1D AND QUESTIONTEXT = N'Coin Change (min coins) initializes dp[0] to:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_DP_1D, NULL, N'Coin Change (min coins) initializes dp[0] to:', N'Infinity', N'0', N'-1', N'1',
         N'B', N'Zero amount needs zero coins; others start at +∞.', N'MEDIUM', 2, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Infinity', OPTIONB = N'0', OPTIONC = N'-1', OPTIOND = N'1',
        CORRECTOPTION = N'B', EXPLANATION = N'Zero amount needs zero coins; others start at +∞.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 2, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_DP_1D AND QUESTIONTEXT = N'Coin Change (min coins) initializes dp[0] to:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_DP_1D AND DISPLAYORDER = 3 AND QUESTIONTEXT = N'Word Break dp[i] true means:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_DP_1D AND QUESTIONTEXT = N'Word Break dp[i] true means:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_DP_1D, NULL, N'Word Break dp[i] true means:', N's[0..i) can be segmented into dictionary words', N's[i] is a vowel', N'i is prime', N'Only one word matches',
         N'A', N'Try breaks j < i where dp[j] and s[j..i) ∈ dict.', N'MEDIUM', 3, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N's[0..i) can be segmented into dictionary words', OPTIONB = N's[i] is a vowel', OPTIONC = N'i is prime', OPTIOND = N'Only one word matches',
        CORRECTOPTION = N'A', EXPLANATION = N'Try breaks j < i where dp[j] and s[j..i) ∈ dict.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 3, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_DP_1D AND QUESTIONTEXT = N'Word Break dp[i] true means:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_DP_1D AND DISPLAYORDER = 4 AND QUESTIONTEXT = N'LIS O(n log n) maintains:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_DP_1D AND QUESTIONTEXT = N'LIS O(n log n) maintains:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_DP_1D, NULL, N'LIS O(n log n) maintains:', N'A Fenwick of random keys', N'An array of smallest tails of all increasing subsequences of each length', N'Only the maximum element', N'A BFS queue',
         N'B', N'Binary search replacement in tails array.', N'HARD', 4, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'A Fenwick of random keys', OPTIONB = N'An array of smallest tails of all increasing subsequences of each length', OPTIONC = N'Only the maximum element', OPTIOND = N'A BFS queue',
        CORRECTOPTION = N'B', EXPLANATION = N'Binary search replacement in tails array.', DIFFICULTY = N'HARD',
        DISPLAYORDER = 4, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_DP_1D AND QUESTIONTEXT = N'LIS O(n log n) maintains:';
END

/* ---- Topic 16: Multidimensional DP ---- */
IF NOT EXISTS (SELECT 1 FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'DP_2D')
BEGIN
    INSERT INTO dbo.TOPIC_MASTER
        (PATHID, TOPICKEY, TOPICNAME, DESCRIPTION, DIFFICULTYTIER, DISPLAYORDER,
         PREREQUISITETOPICID, ESTIMATEDMINUTES, THEORYMARKDOWN, ISACTIVE)
    VALUES
        (@PATHID, N'DP_2D', N'Multidimensional DP', N'Grid and string DP: Unique Paths, Minimum Path Sum, Longest Common Subsequence, Edit Distance, Best Time to Buy and Sell Stock III/IV patterns where present in Top 150.', N'ADVANCED', 16,
         (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'DP_1D'),
         95, N'# Multidimensional DP

## Grid
- **Unique Paths** — dp[i][j] = from top + from left.
- **Minimum Path Sum** — same DAG with costs.
- **Triangle / dungeon** variants — bottom-up often cleaner.

## Strings
- **LCS** — dp[i][j] from prefixes.
- **Edit Distance** — insert/delete/replace transitions.
- **Interleaving String** — 2D boolean reachability.

## Optimization
Rolling arrays when only previous row/column needed.', 1);
END
ELSE
BEGIN
    UPDATE dbo.TOPIC_MASTER
    SET TOPICNAME = N'Multidimensional DP',
        DESCRIPTION = N'Grid and string DP: Unique Paths, Minimum Path Sum, Longest Common Subsequence, Edit Distance, Best Time to Buy and Sell Stock III/IV patterns where present in Top 150.',
        DIFFICULTYTIER = N'ADVANCED',
        DISPLAYORDER = 16,
        PREREQUISITETOPICID = (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'DP_1D'),
        ESTIMATEDMINUTES = 95,
        THEORYMARKDOWN = N'# Multidimensional DP

## Grid
- **Unique Paths** — dp[i][j] = from top + from left.
- **Minimum Path Sum** — same DAG with costs.
- **Triangle / dungeon** variants — bottom-up often cleaner.

## Strings
- **LCS** — dp[i][j] from prefixes.
- **Edit Distance** — insert/delete/replace transitions.
- **Interleaving String** — 2D boolean reachability.

## Optimization
Rolling arrays when only previous row/column needed.',
        ISACTIVE = 1,
        UPDATEDDATE = SYSUTCDATETIME()
    WHERE PATHID = @PATHID AND TOPICKEY = N'DP_2D';
END
SELECT @T_DP_2D = TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'DP_2D';

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_DP_2D AND EXTERNALURL = N'https://leetcode.com/problems/unique-paths-ii/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_DP_2D, N'PROBLEM', N'Unique Paths II', N'Grid paths with obstacles.', N'https://leetcode.com/problems/unique-paths-ii/', N'LEETCODE', N'MEDIUM', 1, 25, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Unique Paths II', SUMMARY = N'Grid paths with obstacles.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 1, ESTIMATEDMINUTES = 25,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_DP_2D AND EXTERNALURL = N'https://leetcode.com/problems/unique-paths-ii/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_DP_2D AND EXTERNALURL = N'https://leetcode.com/problems/minimum-path-sum/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_DP_2D, N'PROBLEM', N'Minimum Path Sum', N'Min cost path in grid.', N'https://leetcode.com/problems/minimum-path-sum/', N'LEETCODE', N'MEDIUM', 2, 25, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Minimum Path Sum', SUMMARY = N'Min cost path in grid.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 2, ESTIMATEDMINUTES = 25,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_DP_2D AND EXTERNALURL = N'https://leetcode.com/problems/minimum-path-sum/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_DP_2D AND EXTERNALURL = N'https://leetcode.com/problems/longest-common-subsequence/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_DP_2D, N'PROBLEM', N'Longest Common Subsequence', N'Classic 2D string DP.', N'https://leetcode.com/problems/longest-common-subsequence/', N'LEETCODE', N'MEDIUM', 3, 30, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Longest Common Subsequence', SUMMARY = N'Classic 2D string DP.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 3, ESTIMATEDMINUTES = 30,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_DP_2D AND EXTERNALURL = N'https://leetcode.com/problems/longest-common-subsequence/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_DP_2D AND EXTERNALURL = N'https://leetcode.com/problems/best-time-to-buy-and-sell-stock-iii/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_DP_2D, N'PROBLEM', N'Best Time to Buy and Sell Stock III', N'At most two transactions DP.', N'https://leetcode.com/problems/best-time-to-buy-and-sell-stock-iii/', N'LEETCODE', N'HARD', 4, 40, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Best Time to Buy and Sell Stock III', SUMMARY = N'At most two transactions DP.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'HARD', DISPLAYORDER = 4, ESTIMATEDMINUTES = 40,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_DP_2D AND EXTERNALURL = N'https://leetcode.com/problems/best-time-to-buy-and-sell-stock-iii/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_DP_2D AND EXTERNALURL = N'https://leetcode.com/problems/best-time-to-buy-and-sell-stock-iv/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_DP_2D, N'PROBLEM', N'Best Time to Buy and Sell Stock IV', N'At most k transactions.', N'https://leetcode.com/problems/best-time-to-buy-and-sell-stock-iv/', N'LEETCODE', N'HARD', 5, 45, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Best Time to Buy and Sell Stock IV', SUMMARY = N'At most k transactions.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'HARD', DISPLAYORDER = 5, ESTIMATEDMINUTES = 45,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_DP_2D AND EXTERNALURL = N'https://leetcode.com/problems/best-time-to-buy-and-sell-stock-iv/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_DP_2D AND EXTERNALURL = N'https://leetcode.com/problems/edit-distance/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_DP_2D, N'PROBLEM', N'Edit Distance', N'Levenshtein DP.', N'https://leetcode.com/problems/edit-distance/', N'LEETCODE', N'MEDIUM', 6, 35, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Edit Distance', SUMMARY = N'Levenshtein DP.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 6, ESTIMATEDMINUTES = 35,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_DP_2D AND EXTERNALURL = N'https://leetcode.com/problems/edit-distance/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_DP_2D AND CONTENTTYPE = N'THEORY' AND TITLE = N'Multidimensional DP — Theory')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_DP_2D, N'THEORY', N'Multidimensional DP — Theory', N'Interview-oriented theory for Multidimensional DP (Top 150 patterns).', NULL, N'STREAKLY', N'MEDIUM', 0, 20, 1);
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_DP_2D AND DISPLAYORDER = 1 AND QUESTIONTEXT = N'Minimum Path Sum only moves right/down; dp[i][j] equals:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_DP_2D AND QUESTIONTEXT = N'Minimum Path Sum only moves right/down; dp[i][j] equals:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_DP_2D, NULL, N'Minimum Path Sum only moves right/down; dp[i][j] equals:', N'grid[i][j] + min(dp[i-1][j], dp[i][j-1]) (edges handled)', N'max of entire grid', N'XOR of path', N'BFS distance only',
         N'A', N'DAG DP on grid.', N'EASY', 1, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'grid[i][j] + min(dp[i-1][j], dp[i][j-1]) (edges handled)', OPTIONB = N'max of entire grid', OPTIONC = N'XOR of path', OPTIOND = N'BFS distance only',
        CORRECTOPTION = N'A', EXPLANATION = N'DAG DP on grid.', DIFFICULTY = N'EASY',
        DISPLAYORDER = 1, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_DP_2D AND QUESTIONTEXT = N'Minimum Path Sum only moves right/down; dp[i][j] equals:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_DP_2D AND DISPLAYORDER = 2 AND QUESTIONTEXT = N'LCS when characters equal:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_DP_2D AND QUESTIONTEXT = N'LCS when characters equal:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_DP_2D, NULL, N'LCS when characters equal:', N'dp[i][j] = dp[i-1][j-1] + 1', N'dp[i][j] = 0', N'dp[i][j] = i + j', N'Delete both always',
         N'A', N'Else take max of skip either char.', N'MEDIUM', 2, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'dp[i][j] = dp[i-1][j-1] + 1', OPTIONB = N'dp[i][j] = 0', OPTIONC = N'dp[i][j] = i + j', OPTIOND = N'Delete both always',
        CORRECTOPTION = N'A', EXPLANATION = N'Else take max of skip either char.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 2, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_DP_2D AND QUESTIONTEXT = N'LCS when characters equal:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_DP_2D AND DISPLAYORDER = 3 AND QUESTIONTEXT = N'Edit Distance replace transition uses:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_DP_2D AND QUESTIONTEXT = N'Edit Distance replace transition uses:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_DP_2D, NULL, N'Edit Distance replace transition uses:', N'dp[i-1][j-1] + cost(replace)', N'Only dp[i][j-1]', N'Sorting', N'Heap merge',
         N'A', N'Also consider insert (dp[i][j-1]) and delete (dp[i-1][j]).', N'MEDIUM', 3, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'dp[i-1][j-1] + cost(replace)', OPTIONB = N'Only dp[i][j-1]', OPTIONC = N'Sorting', OPTIOND = N'Heap merge',
        CORRECTOPTION = N'A', EXPLANATION = N'Also consider insert (dp[i][j-1]) and delete (dp[i-1][j]).', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 3, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_DP_2D AND QUESTIONTEXT = N'Edit Distance replace transition uses:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_DP_2D AND DISPLAYORDER = 4 AND QUESTIONTEXT = N'Stock DP with at most k transactions models state as:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_DP_2D AND QUESTIONTEXT = N'Stock DP with at most k transactions models state as:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_DP_2D, NULL, N'Stock DP with at most k transactions models state as:', N'Only current price', N'Day × transaction count × holding/not holding (or compressed)', N'Trie of prices', N'Union-Find of days',
         N'B', N'Classic finite-state machine DP on time.', N'HARD', 4, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Only current price', OPTIONB = N'Day × transaction count × holding/not holding (or compressed)', OPTIONC = N'Trie of prices', OPTIOND = N'Union-Find of days',
        CORRECTOPTION = N'B', EXPLANATION = N'Classic finite-state machine DP on time.', DIFFICULTY = N'HARD',
        DISPLAYORDER = 4, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_DP_2D AND QUESTIONTEXT = N'Stock DP with at most k transactions models state as:';
END

/* ---- Topic 17: Bit Manipulation & Math ---- */
IF NOT EXISTS (SELECT 1 FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'BIT_MATH')
BEGIN
    INSERT INTO dbo.TOPIC_MASTER
        (PATHID, TOPICKEY, TOPICNAME, DESCRIPTION, DIFFICULTYTIER, DISPLAYORDER,
         PREREQUISITETOPICID, ESTIMATEDMINUTES, THEORYMARKDOWN, ISACTIVE)
    VALUES
        (@PATHID, N'BIT_MATH', N'Bit Manipulation & Math', N'Bit tricks and number theory style Top 150: Single Number, Number of 1 Bits, Reverse Bits, Plus One, Sqrt(x), Pow(x,n), Factorial Trailing Zeroes.', N'INTERMEDIATE', 17,
         (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'DP_2D'),
         60, N'# Bit Manipulation & Math

## Bits
- **Single Number** — XOR all (a⊕a=0).
- **Hamming weight** — `n &= n-1` clears lowest set bit.
- **Reverse Bits** — shift build.

## Math
- **Pow(x, n)** — binary exponentiation.
- **Sqrt(x)** — binary search integer root.
- **Trailing Zeroes** — count factors of 5.
- **Plus One** — digit array carry.

## Interview habit
State overflow / negative `n` handling for pow.', 1);
END
ELSE
BEGIN
    UPDATE dbo.TOPIC_MASTER
    SET TOPICNAME = N'Bit Manipulation & Math',
        DESCRIPTION = N'Bit tricks and number theory style Top 150: Single Number, Number of 1 Bits, Reverse Bits, Plus One, Sqrt(x), Pow(x,n), Factorial Trailing Zeroes.',
        DIFFICULTYTIER = N'INTERMEDIATE',
        DISPLAYORDER = 17,
        PREREQUISITETOPICID = (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'DP_2D'),
        ESTIMATEDMINUTES = 60,
        THEORYMARKDOWN = N'# Bit Manipulation & Math

## Bits
- **Single Number** — XOR all (a⊕a=0).
- **Hamming weight** — `n &= n-1` clears lowest set bit.
- **Reverse Bits** — shift build.

## Math
- **Pow(x, n)** — binary exponentiation.
- **Sqrt(x)** — binary search integer root.
- **Trailing Zeroes** — count factors of 5.
- **Plus One** — digit array carry.

## Interview habit
State overflow / negative `n` handling for pow.',
        ISACTIVE = 1,
        UPDATEDDATE = SYSUTCDATETIME()
    WHERE PATHID = @PATHID AND TOPICKEY = N'BIT_MATH';
END
SELECT @T_BIT_MATH = TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'BIT_MATH';

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BIT_MATH AND EXTERNALURL = N'https://leetcode.com/problems/single-number/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BIT_MATH, N'PROBLEM', N'Single Number', N'XOR accumulation.', N'https://leetcode.com/problems/single-number/', N'LEETCODE', N'EASY', 1, 10, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Single Number', SUMMARY = N'XOR accumulation.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 1, ESTIMATEDMINUTES = 10,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BIT_MATH AND EXTERNALURL = N'https://leetcode.com/problems/single-number/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BIT_MATH AND EXTERNALURL = N'https://leetcode.com/problems/number-of-1-bits/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BIT_MATH, N'PROBLEM', N'Number of 1 Bits', N'Brian Kernighan count.', N'https://leetcode.com/problems/number-of-1-bits/', N'LEETCODE', N'EASY', 2, 10, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Number of 1 Bits', SUMMARY = N'Brian Kernighan count.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 2, ESTIMATEDMINUTES = 10,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BIT_MATH AND EXTERNALURL = N'https://leetcode.com/problems/number-of-1-bits/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BIT_MATH AND EXTERNALURL = N'https://leetcode.com/problems/reverse-bits/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BIT_MATH, N'PROBLEM', N'Reverse Bits', N'Shift construction.', N'https://leetcode.com/problems/reverse-bits/', N'LEETCODE', N'EASY', 3, 15, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Reverse Bits', SUMMARY = N'Shift construction.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 3, ESTIMATEDMINUTES = 15,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BIT_MATH AND EXTERNALURL = N'https://leetcode.com/problems/reverse-bits/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BIT_MATH AND EXTERNALURL = N'https://leetcode.com/problems/plus-one/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BIT_MATH, N'PROBLEM', N'Plus One', N'Digit carry.', N'https://leetcode.com/problems/plus-one/', N'LEETCODE', N'EASY', 4, 10, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Plus One', SUMMARY = N'Digit carry.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 4, ESTIMATEDMINUTES = 10,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BIT_MATH AND EXTERNALURL = N'https://leetcode.com/problems/plus-one/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BIT_MATH AND EXTERNALURL = N'https://leetcode.com/problems/sqrtx/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BIT_MATH, N'PROBLEM', N'Sqrt(x)', N'Binary search integer square root.', N'https://leetcode.com/problems/sqrtx/', N'LEETCODE', N'EASY', 5, 20, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Sqrt(x)', SUMMARY = N'Binary search integer square root.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'EASY', DISPLAYORDER = 5, ESTIMATEDMINUTES = 20,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BIT_MATH AND EXTERNALURL = N'https://leetcode.com/problems/sqrtx/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BIT_MATH AND EXTERNALURL = N'https://leetcode.com/problems/powx-n/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BIT_MATH, N'PROBLEM', N'Pow(x, n)', N'Fast power; handle negative n.', N'https://leetcode.com/problems/powx-n/', N'LEETCODE', N'MEDIUM', 6, 25, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Pow(x, n)', SUMMARY = N'Fast power; handle negative n.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 6, ESTIMATEDMINUTES = 25,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BIT_MATH AND EXTERNALURL = N'https://leetcode.com/problems/powx-n/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BIT_MATH AND EXTERNALURL = N'https://leetcode.com/problems/factorial-trailing-zeroes/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BIT_MATH, N'PROBLEM', N'Factorial Trailing Zeroes', N'Count factors of 5.', N'https://leetcode.com/problems/factorial-trailing-zeroes/', N'LEETCODE', N'MEDIUM', 7, 20, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Factorial Trailing Zeroes', SUMMARY = N'Count factors of 5.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 7, ESTIMATEDMINUTES = 20,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BIT_MATH AND EXTERNALURL = N'https://leetcode.com/problems/factorial-trailing-zeroes/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_BIT_MATH AND CONTENTTYPE = N'THEORY' AND TITLE = N'Bit Manipulation & Math — Theory')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_BIT_MATH, N'THEORY', N'Bit Manipulation & Math — Theory', N'Interview-oriented theory for Bit Manipulation & Math (Top 150 patterns).', NULL, N'STREAKLY', N'MEDIUM', 0, 20, 1);
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BIT_MATH AND DISPLAYORDER = 1 AND QUESTIONTEXT = N'XOR of all elements finds the single number because:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BIT_MATH AND QUESTIONTEXT = N'XOR of all elements finds the single number because:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_BIT_MATH, NULL, N'XOR of all elements finds the single number because:', N'x⊕x = 0 and 0⊕y = y', N'XOR sorts the array', N'XOR counts bits in O(n²)', N'XOR needs sorted input',
         N'A', N'Pairs cancel; unique remains.', N'EASY', 1, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'x⊕x = 0 and 0⊕y = y', OPTIONB = N'XOR sorts the array', OPTIONC = N'XOR counts bits in O(n²)', OPTIOND = N'XOR needs sorted input',
        CORRECTOPTION = N'A', EXPLANATION = N'Pairs cancel; unique remains.', DIFFICULTY = N'EASY',
        DISPLAYORDER = 1, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BIT_MATH AND QUESTIONTEXT = N'XOR of all elements finds the single number because:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BIT_MATH AND DISPLAYORDER = 2 AND QUESTIONTEXT = N'n & (n-1) is used to:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BIT_MATH AND QUESTIONTEXT = N'n & (n-1) is used to:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_BIT_MATH, NULL, N'n & (n-1) is used to:', N'Set the highest bit', N'Clear the lowest set bit', N'Multiply by 2', N'Compute GCD',
         N'B', N'Loop until n==0 for popcount.', N'EASY', 2, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Set the highest bit', OPTIONB = N'Clear the lowest set bit', OPTIONC = N'Multiply by 2', OPTIOND = N'Compute GCD',
        CORRECTOPTION = N'B', EXPLANATION = N'Loop until n==0 for popcount.', DIFFICULTY = N'EASY',
        DISPLAYORDER = 2, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BIT_MATH AND QUESTIONTEXT = N'n & (n-1) is used to:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BIT_MATH AND DISPLAYORDER = 3 AND QUESTIONTEXT = N'Trailing zeroes in n! equal:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BIT_MATH AND QUESTIONTEXT = N'Trailing zeroes in n! equal:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_BIT_MATH, NULL, N'Trailing zeroes in n! equal:', N'n/2', N'Number of times 5 divides numbers ≤ n (including 25, 125, …)', N'Number of even factors only', N'log2(n)',
         N'B', N'Each 5 pairs with a 2 to make a trailing zero.', N'MEDIUM', 3, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'n/2', OPTIONB = N'Number of times 5 divides numbers ≤ n (including 25, 125, …)', OPTIONC = N'Number of even factors only', OPTIOND = N'log2(n)',
        CORRECTOPTION = N'B', EXPLANATION = N'Each 5 pairs with a 2 to make a trailing zero.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 3, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BIT_MATH AND QUESTIONTEXT = N'Trailing zeroes in n! equal:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BIT_MATH AND DISPLAYORDER = 4 AND QUESTIONTEXT = N'Binary exponentiation computes pow by:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_BIT_MATH AND QUESTIONTEXT = N'Binary exponentiation computes pow by:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_BIT_MATH, NULL, N'Binary exponentiation computes pow by:', N'Multiplying x, n times always', N'Squaring and consuming bits of the exponent', N'DFS on digits', N'Heap of powers',
         N'B', N'O(log |n|) multiplications.', N'MEDIUM', 4, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Multiplying x, n times always', OPTIONB = N'Squaring and consuming bits of the exponent', OPTIONC = N'DFS on digits', OPTIOND = N'Heap of powers',
        CORRECTOPTION = N'B', EXPLANATION = N'O(log |n|) multiplications.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 4, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_BIT_MATH AND QUESTIONTEXT = N'Binary exponentiation computes pow by:';
END

/* ---- Topic 18: Union Find ---- */
IF NOT EXISTS (SELECT 1 FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'UNION_FIND')
BEGIN
    INSERT INTO dbo.TOPIC_MASTER
        (PATHID, TOPICKEY, TOPICNAME, DESCRIPTION, DIFFICULTYTIER, DISPLAYORDER,
         PREREQUISITETOPICID, ESTIMATEDMINUTES, THEORYMARKDOWN, ISACTIVE)
    VALUES
        (@PATHID, N'UNION_FIND', N'Union Find', N'Disjoint sets for connectivity-style Top 150 items such as Number of Provinces and graph connectivity variants.', N'ADVANCED', 18,
         (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'BIT_MATH'),
         50, N'# Union-Find (DSU)

## API
- `find(x)` with path compression.
- `union(a,b)` with union by rank/size.

## Top 150 fit
- **Number of Provinces** — union connected cities; count roots.
- Connectivity queries / redundant connection style problems.

## Complexity
Almost O(1) per op with both optimizations (inverse Ackermann).', 1);
END
ELSE
BEGIN
    UPDATE dbo.TOPIC_MASTER
    SET TOPICNAME = N'Union Find',
        DESCRIPTION = N'Disjoint sets for connectivity-style Top 150 items such as Number of Provinces and graph connectivity variants.',
        DIFFICULTYTIER = N'ADVANCED',
        DISPLAYORDER = 18,
        PREREQUISITETOPICID = (SELECT TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'BIT_MATH'),
        ESTIMATEDMINUTES = 50,
        THEORYMARKDOWN = N'# Union-Find (DSU)

## API
- `find(x)` with path compression.
- `union(a,b)` with union by rank/size.

## Top 150 fit
- **Number of Provinces** — union connected cities; count roots.
- Connectivity queries / redundant connection style problems.

## Complexity
Almost O(1) per op with both optimizations (inverse Ackermann).',
        ISACTIVE = 1,
        UPDATEDDATE = SYSUTCDATETIME()
    WHERE PATHID = @PATHID AND TOPICKEY = N'UNION_FIND';
END
SELECT @T_UNION_FIND = TOPICID FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID AND TOPICKEY = N'UNION_FIND';

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_UNION_FIND AND EXTERNALURL = N'https://leetcode.com/problems/number-of-provinces/')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_UNION_FIND, N'PROBLEM', N'Number of Provinces', N'DSU or DFS components on matrix.', N'https://leetcode.com/problems/number-of-provinces/', N'LEETCODE', N'MEDIUM', 1, 25, 1);
END
ELSE
BEGIN
    UPDATE dbo.CONTENT_ITEM
    SET TITLE = N'Number of Provinces', SUMMARY = N'DSU or DFS components on matrix.', PLATFORMCODE = N'LEETCODE',
        DIFFICULTY = N'MEDIUM', DISPLAYORDER = 1, ESTIMATEDMINUTES = 25,
        ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_UNION_FIND AND EXTERNALURL = N'https://leetcode.com/problems/number-of-provinces/';
END

IF NOT EXISTS (SELECT 1 FROM dbo.CONTENT_ITEM WHERE TOPICID = @T_UNION_FIND AND CONTENTTYPE = N'THEORY' AND TITLE = N'Union Find — Theory')
BEGIN
    INSERT INTO dbo.CONTENT_ITEM
        (TOPICID, CONTENTTYPE, TITLE, SUMMARY, EXTERNALURL, PLATFORMCODE, DIFFICULTY, DISPLAYORDER, ESTIMATEDMINUTES, ISACTIVE)
    VALUES
        (@T_UNION_FIND, N'THEORY', N'Union Find — Theory', N'Interview-oriented theory for Union Find (Top 150 patterns).', NULL, N'STREAKLY', N'MEDIUM', 0, 20, 1);
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_UNION_FIND AND DISPLAYORDER = 1 AND QUESTIONTEXT = N'Path compression in find():'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_UNION_FIND AND QUESTIONTEXT = N'Path compression in find():'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_UNION_FIND, NULL, N'Path compression in find():', N'Deletes all nodes', N'Points nodes directly toward the root along the lookup path', N'Sorts children', N'Builds a segment tree',
         N'B', N'Flattens trees for faster future finds.', N'MEDIUM', 1, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Deletes all nodes', OPTIONB = N'Points nodes directly toward the root along the lookup path', OPTIONC = N'Sorts children', OPTIOND = N'Builds a segment tree',
        CORRECTOPTION = N'B', EXPLANATION = N'Flattens trees for faster future finds.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 1, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_UNION_FIND AND QUESTIONTEXT = N'Path compression in find():';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_UNION_FIND AND DISPLAYORDER = 2 AND QUESTIONTEXT = N'Union by rank prefers attaching:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_UNION_FIND AND QUESTIONTEXT = N'Union by rank prefers attaching:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_UNION_FIND, NULL, N'Union by rank prefers attaching:', N'Larger rank tree under smaller', N'Smaller rank tree under larger rank root', N'Random trees only', N'Only leaves',
         N'B', N'Keeps tree shallow.', N'EASY', 2, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Larger rank tree under smaller', OPTIONB = N'Smaller rank tree under larger rank root', OPTIONC = N'Random trees only', OPTIOND = N'Only leaves',
        CORRECTOPTION = N'B', EXPLANATION = N'Keeps tree shallow.', DIFFICULTY = N'EASY',
        DISPLAYORDER = 2, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_UNION_FIND AND QUESTIONTEXT = N'Union by rank prefers attaching:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_UNION_FIND AND DISPLAYORDER = 3 AND QUESTIONTEXT = N'Number of Provinces with DSU equals:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_UNION_FIND AND QUESTIONTEXT = N'Number of Provinces with DSU equals:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_UNION_FIND, NULL, N'Number of Provinces with DSU equals:', N'n always', N'Count of distinct roots after processing edges/adjacency', N'Number of 0s in the matrix', N'Graph diameter',
         N'B', N'Each remaining component has one representative.', N'EASY', 3, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'n always', OPTIONB = N'Count of distinct roots after processing edges/adjacency', OPTIONC = N'Number of 0s in the matrix', OPTIOND = N'Graph diameter',
        CORRECTOPTION = N'B', EXPLANATION = N'Each remaining component has one representative.', DIFFICULTY = N'EASY',
        DISPLAYORDER = 3, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_UNION_FIND AND QUESTIONTEXT = N'Number of Provinces with DSU equals:';
END

IF NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_UNION_FIND AND DISPLAYORDER = 4 AND QUESTIONTEXT = N'DSU is a poor fit when you need:'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.QUIZ_QUESTION_MASTER
    WHERE TOPICID = @T_UNION_FIND AND QUESTIONTEXT = N'DSU is a poor fit when you need:'
)
BEGIN
    INSERT INTO dbo.QUIZ_QUESTION_MASTER
        (TOPICID, CONTENTID, QUESTIONTEXT, OPTIONA, OPTIONB, OPTIONC, OPTIOND,
         CORRECTOPTION, EXPLANATION, DIFFICULTY, DISPLAYORDER, ISACTIVE)
    VALUES
        (@T_UNION_FIND, NULL, N'DSU is a poor fit when you need:', N'Dynamic connectivity of undirected edges', N'Shortest path distances', N'Component counting', N'Cycle detection in undirected add-edge streams (sometimes OK)',
         N'B', N'Use BFS/Dijkstra for distances; DSU tracks membership.', N'MEDIUM', 4, 1);
END
ELSE
BEGIN
    UPDATE dbo.QUIZ_QUESTION_MASTER
    SET OPTIONA = N'Dynamic connectivity of undirected edges', OPTIONB = N'Shortest path distances', OPTIONC = N'Component counting', OPTIOND = N'Cycle detection in undirected add-edge streams (sometimes OK)',
        CORRECTOPTION = N'B', EXPLANATION = N'Use BFS/Dijkstra for distances; DSU tracks membership.', DIFFICULTY = N'MEDIUM',
        DISPLAYORDER = 4, ISACTIVE = 1, UPDATEDDATE = SYSUTCDATETIME()
    WHERE TOPICID = @T_UNION_FIND AND QUESTIONTEXT = N'DSU is a poor fit when you need:';
END

/* Verification */
SELECT 'PATH' AS KIND, PATHID, PATHKEY, PATHNAME FROM dbo.LEARNING_PATH_MASTER WHERE PATHID = @PATHID;
SELECT COUNT(*) AS TOPIC_COUNT FROM dbo.TOPIC_MASTER WHERE PATHID = @PATHID;
SELECT COUNT(*) AS CONTENT_COUNT
FROM dbo.CONTENT_ITEM CI
INNER JOIN dbo.TOPIC_MASTER T ON T.TOPICID = CI.TOPICID
WHERE T.PATHID = @PATHID;
SELECT COUNT(*) AS QUIZ_COUNT
FROM dbo.QUIZ_QUESTION_MASTER QQ
INNER JOIN dbo.TOPIC_MASTER T ON T.TOPICID = QQ.TOPICID
WHERE T.PATHID = @PATHID;
SELECT T.TOPICKEY, T.TOPICNAME,
       (SELECT COUNT(*) FROM dbo.CONTENT_ITEM C WHERE C.TOPICID = T.TOPICID AND C.ISACTIVE = 1) AS CONTENTS,
       (SELECT COUNT(*) FROM dbo.QUIZ_QUESTION_MASTER Q WHERE Q.TOPICID = T.TOPICID AND Q.ISACTIVE = 1) AS QUESTIONS
FROM dbo.TOPIC_MASTER T
WHERE T.PATHID = @PATHID
ORDER BY T.DISPLAYORDER;

COMMIT TRANSACTION;
GO
PRINT 'DSA_TOP150 seed completed successfully.';
GO