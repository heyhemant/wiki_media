import 'dart:math';
import 'package:flutter/foundation.dart';
import 'profile_service.dart';
import 'database_helper.dart';

class CandidatePost {
  final int id;
  final Set<String> categories;
  final bool hasThumb;
  double score;

  CandidatePost({
    required this.id,
    required this.categories,
    required this.hasThumb,
    required this.score,
  });
}

class FeedAlgorithm {
  static final FeedAlgorithm _instance = FeedAlgorithm._internal();
  factory FeedAlgorithm() => _instance;
  FeedAlgorithm._internal();

  final Random _random = Random();

  /// Selects the next post ID using the 3-way weighted recommendation algorithm.
  /// Fetches 10,000 candidates from the database and scores them in a background Isolate.
  Future<int> getNextPostId() async {
    // 1. Fetch random candidates directly from SQLite for better performance and lower RAM usage
    final rawCandidates = await DatabaseHelper().getRandomScoringCandidates(500);
    
    if (rawCandidates.isEmpty) {
      throw Exception('Database is empty or not yet populated.');
    }

    // 2. Prepare parameters for background scoring
    final profile = ProfileService();
    final Map<String, dynamic> scoringParams = {
      'rawCandidates': rawCandidates,
      'categoryScores': profile.categoryScores,
      'seenPosts': profile.seenPosts,
      'randomSeed': _random.nextInt(1000000),
    };

    // 3. Run scoring in background isolate to keep UI responsive
    return await compute(_scoreCandidatesIsolate, scoringParams);
  }
}

/// Background isolate for processing candidate scores
int _scoreCandidatesIsolate(Map<String, dynamic> params) {
  final List<Map<String, dynamic>> rawCandidates = params['rawCandidates'];
  final Map<String, int> categoryScores = params['categoryScores'];
  final List<int> seenPosts = params['seenPosts'];
  final int randomSeed = params['randomSeed'];
  
  final Random random = Random(randomSeed);

  // Create seen counts map for penalty calculations
  final Map<int, int> seenCounts = {};
  for (final id in seenPosts) {
    seenCounts[id] = (seenCounts[id] ?? 0) + 1;
  }

  final List<CandidatePost> candidates = [];

  for (final raw in rawCandidates) {
    final int id = raw['id'] as int;
    final String allCatsStr = raw['all_categories'] as String;
    final categories = allCatsStr.split(',').toSet();
    
    // Check for thumbnail existence directly from the raw DB row
    final String? thumb = raw['thumb'] as String?;
    final hasThumb = thumb != null && thumb.trim().isNotEmpty;

    final seen = seenCounts[id] ?? 0;
    // Formula: (3**seen - 1) * -50000
    final double seenPenalty = (pow(3, seen) - 1) * -50000.0;
    final double initialScore = (hasThumb ? 5.0 : 0.0) + seenPenalty;

    double score = initialScore;
    for (final cat in categories) {
      score += categoryScores[cat] ?? 0;
    }

    candidates.add(CandidatePost(
      id: id,
      categories: categories,
      hasThumb: hasThumb,
      score: score,
    ));
  }

  if (candidates.isEmpty) return 0;

  CandidatePost bestPost = candidates.first;
  final double roll = random.nextDouble();

  if (roll < 0.40) {
    // 40% chance: Weighted random selection
    final double minScore = candidates.map((e) => e.score).reduce((a, b) => a < b ? a : b);
    final double maxScoreSum = candidates.fold<double>(0.0, (sum, post) => sum + (post.score - minScore));

    if (maxScoreSum > 0) {
      final double targetScore = random.nextDouble() * maxScoreSum;
      double scoreCount = 0.0;
      
      for (final post in candidates) {
        scoreCount += post.score - minScore;
        if (scoreCount >= targetScore) {
          bestPost = post;
          break;
        }
      }
    } else {
      bestPost = candidates[random.nextInt(candidates.length)];
    }
  } else if (roll > 0.40 + 0.18) {
    // 42% chance: Show the post with the highest score
    double highestScore = double.negativeInfinity;
    for (final post in candidates) {
      if (post.score > highestScore) {
        bestPost = post;
        highestScore = post.score;
      }
    }
  } else {
    // 18% chance: Completely random post
    bestPost = candidates[random.nextInt(candidates.length)];
  }

  return bestPost.id;
}
