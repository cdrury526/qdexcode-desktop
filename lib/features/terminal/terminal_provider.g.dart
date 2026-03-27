// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'terminal_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$terminalShowLocalPathHintHash() =>
    r'c7482ca8d1d8437c123efc0dbd2537ac70506c89';

/// True when the selected project has no [localPath] set.
///
/// The terminal page can show a non-intrusive hint suggesting the user
/// configure a local path so terminals open in the project directory.
///
/// Copied from [terminalShowLocalPathHint].
@ProviderFor(terminalShowLocalPathHint)
final terminalShowLocalPathHintProvider = AutoDisposeProvider<bool>.internal(
  terminalShowLocalPathHint,
  name: r'terminalShowLocalPathHintProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$terminalShowLocalPathHintHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TerminalShowLocalPathHintRef = AutoDisposeProviderRef<bool>;
String _$terminalSessionsHash() => r'ab70b7d8e28d5fd85895cbda76c269fb4782f2cf';

/// Manages the lifecycle of terminal tabs.
///
/// Kept alive for the app lifetime so terminal sessions persist across
/// workspace tab switches.
///
/// Copied from [TerminalSessions].
@ProviderFor(TerminalSessions)
final terminalSessionsProvider =
    NotifierProvider<TerminalSessions, TerminalSessionState>.internal(
      TerminalSessions.new,
      name: r'terminalSessionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$terminalSessionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TerminalSessions = Notifier<TerminalSessionState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
