import 'package:flutter/material.dart';

/// 별점 위젯
///
/// 사용 예시:
/// ```dart
/// CustomRating(rating: _rating, onRatingChanged: (rating) {})
/// CustomRating(rating: 4.0, readOnly: true)
/// CustomRating(rating: _rating, onRatingChanged: (rating) {}, maxRating: 5, starSize: 32.0)
/// ```
class CustomRating extends StatelessWidget {
  /// 현재 점수 (0~maxRating)
  final double rating;

  /// 점수 변경 시 호출되는 콜백 함수
  final ValueChanged<double>? onRatingChanged;

  /// 최대 별 개수 (기본값: 5)
  final int maxRating;

  /// 읽기 전용 여부 (기본값: false)
  final bool readOnly;

  /// 별 크기 (기본값: 24.0)
  final double starSize;

  /// 채워진 별 색상 (기본값: Colors.amber)
  final Color filledColor;

  /// 비어있는 별 색상 (기본값: Colors.grey)
  final Color unfilledColor;

  /// 별 사이 간격 (기본값: 4.0)
  final double starSpacing;

  /// 반별 선택 허용 여부 (기본값: false, 현재는 사용 안 함)
  final bool allowHalfRating;

  /// 채워진 아이콘 (기본값: Icons.star)
  final IconData filledIcon;

  /// 비어있는 아이콘 (기본값: Icons.star_border)
  final IconData unfilledIcon;

  const CustomRating({
    super.key,
    required this.rating,
    this.onRatingChanged,
    this.maxRating = 5,
    this.readOnly = false,
    this.starSize = 24.0,
    this.filledColor = Colors.amber,
    this.unfilledColor = Colors.grey,
    this.starSpacing = 4.0,
    this.allowHalfRating = false,
    this.filledIcon = Icons.star,
    this.unfilledIcon = Icons.star_border,
  }) : assert(
          rating >= 0 && rating <= maxRating,
          'rating은 0과 maxRating 사이의 값이어야 합니다.',
        ),
        assert(
          maxRating > 0,
          'maxRating은 1 이상이어야 합니다.',
        );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        maxRating,
        (index) {
          final starIndex = index + 1;
          final isFilled = starIndex <= rating;

          Widget starWidget = Icon(
            isFilled ? filledIcon : unfilledIcon,
            size: starSize,
            color: isFilled ? filledColor : unfilledColor,
          );

          // 읽기 전용이 아니고 onRatingChanged가 있으면 클릭 가능
          if (!readOnly && onRatingChanged != null) {
            starWidget = GestureDetector(
              onTap: () {
                onRatingChanged!(starIndex.toDouble());
              },
              child: starWidget,
            );
          }

          // 마지막 별이 아니면 간격 추가
          if (index < maxRating - 1) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                starWidget,
                SizedBox(width: starSpacing),
              ],
            );
          }

          return starWidget;
        },
      ),
    );
  }
}

