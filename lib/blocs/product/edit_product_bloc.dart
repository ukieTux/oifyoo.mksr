import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oifyoo_mksr/blocs/blocs.dart';
import 'package:oifyoo_mksr/data/repositories/repositories.dart';
import 'package:oifyoo_mksr/di/di.dart';

class EditProductBloc extends Cubit<Resources<dynamic>> {
  EditProductBloc() : super(Resources.loading());

  var _productRepo = sl<ProductRepository>();

  editProduct(Map<String, dynamic> _params) async {
    emit(Resources.loading());
    emit(await _productRepo.editProduct(_params));
  }
}
