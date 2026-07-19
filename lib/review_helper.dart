import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewHelper {
  static final InAppReview _inAppReview = InAppReview.instance;

  // Call this whenever a transaction is added.
  // After a few uses, it shows the rating popup once.
  static Future<void> trackAndMaybeAsk() async {
    final prefs = await SharedPreferences.getInstance();

    // If already reviewed, do nothing
    final alreadyReviewed = prefs.getBool('already_reviewed') ?? false;
    if (alreadyReviewed) return;

    // Count actions
    int count = prefs.getInt('action_count') ?? 0;
    count++;
    await prefs.setInt('action_count', count);

    // Show the popup after 5 actions
    if (count == 5) {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
        await prefs.setBool('already_reviewed', true);
      }
    }
  }

  // Manual "Rate us" button — opens the store listing directly
  static Future<void> openStoreListing() async {
    await _inAppReview.openStoreListing();
  }
}