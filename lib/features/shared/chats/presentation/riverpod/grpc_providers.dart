import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/app_chat_grpc_data_source.dart';
import '../../data/repos/app_chat_grbc_repository.dart';

final chatGrpcDataSourceProvider = Provider<AppChatGrpcDataSource>((ref) {
  return AppChatGrpcDataSourceImpl();
});

final chatGrpcRepositoryProvider = Provider<AppChatGrbcRepository>((ref) {
  final dataSource = ref.watch(chatGrpcDataSourceProvider);
  return AppChatGrbcRepository(dataSource: dataSource);
});
