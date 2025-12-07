// parte linsaith
// parte juanjo
import 'package:flutter_test/flutter_test.dart';
import 'package:occitours_app/providers/reviews_provider.dart';
import 'package:occitours_app/models/review.dart';
import '../test_helpers.dart';

void main(){
  setUpAll(() async { await initTestEnvironment(); });

  test('add and find review', () async {
    final prov = ReviewsProvider();
    // wait load
    await Future.delayed(Duration(milliseconds: 200));
    final r = Review(id: 'r1', targetId: 'F1', targetType: 'finca', authorId: 'u1', rating: 5, comment: 'Muy buena');
    await prov.addReview(r);
    final found = prov.findById('r1');
    expect(found, isNotNull);
    expect(found!.rating, 5);
  });
}
