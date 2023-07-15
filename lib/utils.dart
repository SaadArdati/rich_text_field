extension StringExt on String {
  /// [String.splitMapJoin] is limited to [Pattern] which can only do [Match]
  /// and not [RegExpMatch]. Because of this, you can't access named groups
  /// inside the pattern. This function fixes that.
  /// Ref: https://github.com/dart-lang/sdk/issues/52721
  String splitMapJoinRegex(
    RegExp pattern, {
    String Function(RegExpMatch match)? onMatch,
    String Function(String text)? onNonMatch,
  }) {
    return splitMapJoin(
      pattern,
      onMatch: onMatch != null
          ? (match) {
              match as RegExpMatch;
              return onMatch(match);
            }
          : null,
      onNonMatch: onNonMatch != null
          ? (text) {
              return onNonMatch(text);
            }
          : null,
    );
  }

  Iterable<R> splitMap<R>(
    RegExp pattern, {
    R Function(RegExpMatch match)? onMatch,
    R Function(String text)? onNonMatch,
  }) {
    List<R> result = [];
    splitMapJoinRegex(
      pattern,
      onMatch: onMatch != null
          ? (match) {
              result.add(onMatch(match));
              return match[0]!;
            }
          : null,
      onNonMatch: onNonMatch != null
          ? (text) {
              result.add(onNonMatch(text));
              return text;
            }
          : null,
    );
    return result;
  }
}

/// Extensions that apply to all iterables.
///
/// These extensions provide direct access to some of the
/// algorithms expose by this package,
/// as well as some generally useful convenience methods.
///
/// More specialized extension methods that only apply to
/// iterables with specific element types include those of
/// [IterableComparableExtension] and [IterableNullableExtension].
extension IterableExtension<T> on Iterable<T> {

  /// The first element satisfying [test], or `null` if there are none.
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }

}
