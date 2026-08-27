import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/service_repository_impl.dart';
import '../../domain/repositories/service_repository.dart';
import '../../domain/usecases/get_services_usecase.dart';
import '../../domain/usecases/add_service_usecase.dart';
import '../../domain/usecases/upload_media_usecase.dart';
import '../../domain/usecases/remove_service_usecase.dart';
import '../bloc/service_bloc.dart';
import '../bloc/add_service_bloc.dart';
import 'main_category_providers.dart';

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return ServiceRepositoryImpl(
    apiService: ref.watch(mainCategoryApiServiceProvider),
  );
});

final getServicesUseCaseProvider = Provider<GetServicesUseCase>((ref) {
  return GetServicesUseCase(ref.watch(serviceRepositoryProvider));
});

final serviceBlocProvider = Provider.autoDispose<ServiceBloc>((ref) {
  final bloc = ServiceBloc(
    getServicesUseCase: ref.watch(getServicesUseCaseProvider),
  );
  ref.onDispose(() => bloc.close());
  return bloc;
});

final addServiceUseCaseProvider = Provider<AddServiceUseCase>((ref) {
  return AddServiceUseCase(ref.watch(serviceRepositoryProvider));
});

final uploadMediaUseCaseProvider = Provider<UploadMediaUseCase>((ref) {
  return UploadMediaUseCase(ref.watch(serviceRepositoryProvider));
});

final removeServiceUseCaseProvider = Provider<RemoveServiceUseCase>((ref) {
  return RemoveServiceUseCase(ref.watch(serviceRepositoryProvider));
});

final addServiceBlocProvider = Provider.autoDispose<AddServiceBloc>((ref) {
  final bloc = AddServiceBloc(
    addServiceUseCase: ref.watch(addServiceUseCaseProvider),
    uploadMediaUseCase: ref.watch(uploadMediaUseCaseProvider),
    removeServiceUseCase: ref.watch(removeServiceUseCaseProvider),
  );
  ref.onDispose(() => bloc.close());
  return bloc;
});
