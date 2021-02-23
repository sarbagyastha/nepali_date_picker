// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:nepali_utils/nepali_utils.dart';

/// Signature for predicating dates for enabled date selections.
typedef SelectableDayPredicate = bool Function(NepaliDateTime day);

/// Encapsulates a start and end [NepaliDateTime] that represent the range of dates
/// between them.
@immutable
class NepaliDateTimeRange {
  /// Creates a date range for the given start and end [NepaliDateTime].
  ///
  /// [start] and [end] must be non-null.
  const NepaliDateTimeRange({
    required this.start,
    required this.end,
  });

  /// The start of the range of dates.
  final NepaliDateTime start;

  /// The end of the range of dates.
  final NepaliDateTime end;

  /// Returns a [Duration] of the time between [start] and [end].
  ///
  /// See [DateTime.difference] for more details.
  Duration get duration => end.difference(start);

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is NepaliDateTimeRange &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode => hashValues(start, end);

  @override
  String toString() => '$start - $end';
}
