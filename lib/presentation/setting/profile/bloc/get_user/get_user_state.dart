part of 'get_user_bloc.dart';

@freezed
class GetUserState with _$GetUserState {
  const factory GetUserState.initial() = _Initial;
  const factory GetUserState.loading() = _Loading;
  const factory GetUserState.success(User user) = _Success;
  const factory GetUserState.error(String message) = _Error;
}
