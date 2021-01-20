import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oifyoo_mksr/blocs/blocs.dart';
import 'package:oifyoo_mksr/data/models/entities/product_entity.dart';
import 'package:oifyoo_mksr/resources/resources.dart';
import 'package:oifyoo_mksr/utils/utils.dart';
import 'package:oifyoo_mksr/widgets/product_picker.dart';
import 'package:oifyoo_mksr/widgets/widgets.dart';

///*********************************************
/// Created by Mudassir (ukietux) on 1/12/21 with ♥
/// (>’_’)> email : hey.mudassir@gmail.com
/// github : https://www.github.com/ukieTux <(’_’<)
///*********************************************
/// © 2021 | All Right Reserved
class AddSalePage extends StatefulWidget {
  @override
  _AddSalePageState createState() => _AddSalePageState();
}

class _AddSalePageState extends State<AddSalePage> {
  AddSaleBloc _addSaleBloc;
  TransactionNumberSaleBloc _transactionNumberSaleBloc;
  ListProductBloc _listProductBloc;

  var _formKey = GlobalKey<FormState>();

  var _conNote = TextEditingController();
  var _conBuyer = TextEditingController();

  var _fnNote = FocusNode();
  var _fnBuyer = FocusNode();

  var _selectedStatus = "";
  List<ProductEntity> _listProduct = [];
  List<ProductEntity> _listProductFilter = [];
  List<ProductEntity> _listSelectedProduct = [];

  String _transactionNumber = "";
  int _totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _selectedStatus = Strings.listStatus[0];

    _addSaleBloc = BlocProvider.of(context);
    _transactionNumberSaleBloc = BlocProvider.of(context);
    _transactionNumberSaleBloc.transactionNumberSale();
    _listProductBloc = BlocProvider.of(context);
    _listProductBloc.listProduct("");
  }

  @override
  Widget build(BuildContext context) {
    return Parent(
      appBar: context.appBar(title: Strings.addSale),
      avoidBottomInset: true,
      child: MultiBlocListener(
        listeners: [
          BlocListener(
            cubit: _addSaleBloc,
            listener: (_, state) {
              switch (state.status) {
                case Status.LOADING:
                  {
                    Strings.pleaseWait.toToastLoading();
                  }
                  break;
                case Status.ERROR:
                  {
                    state.message.toString().toToastError();
                  }
                  break;
                case Status.SUCCESS:
                  {
                    Strings.successSaveData.toToastSuccess();
                    Navigator.pop(context);
                  }
                  break;
              }
            },
          ),
          BlocListener(
            cubit: _listProductBloc,
            listener: (_, state) {
              switch (state.status) {
                case Status.LOADING:
                  {
                    Strings.pleaseWait.toToastLoading();
                  }
                  break;
                case Status.ERROR:
                  {
                    state.message.toString().toToastError();
                  }
                  break;
                case Status.SUCCESS:
                  {
                    for (var item in state.data) {
                      _listProduct.add(new ProductEntity.clone(item));
                    }
                  }
                  break;
              }
            },
          ),
          BlocListener(
            cubit: _transactionNumberSaleBloc,
            listener: (_, state) {
              switch (state.status) {
                case Status.LOADING:
                  {
                    Strings.pleaseWait.toToastLoading();
                  }
                  break;
                case Status.ERROR:
                  {
                    state.message.toString().toToastError();
                  }
                  break;
                case Status.SUCCESS:
                  {
                    logs("transactionNumber ${state.data}");

                    setState(() {
                      _transactionNumber = state.data;
                    });
                  }
                  break;
              }
            },
          )
        ],
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextD(
                hint: Strings.transactionNumber,
                content: _transactionNumber,
              ),
              ProductPicker(
                label: Strings.product,
                labelButton: Strings.addProduct,
                listProduct: _listProduct,
                listProductFilter: _listProductFilter,
                selectedProduct: (_selected) {
                  setState(() {
                    _listSelectedProduct = _selected;
                    _updateTotal();
                  });
                },
              ),
              Text(
                Strings.productList,
                style: TextStyles.textHint,
              ),
              _listSelectedProduct.isNotEmpty
                  ? ListView.builder(
                      itemCount: _listSelectedProduct.length,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (_, index) {
                        return _listItem(index);
                      })
                  : Empty(errorMessage: Strings.errorNoProduct),
              Visibility(
                  visible: _listSelectedProduct.isNotEmpty,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${Strings.totalDot}",
                        style: TextStyles.textBold
                            .copyWith(fontSize: Dimens.fontLarge),
                      ),
                      Text(
                        _totalPrice.toString().toIDR(),
                        style: TextStyles.textBold
                            .copyWith(fontSize: Dimens.fontLarge1),
                      )
                    ],
                  )),
              SizedBox(height: context.dp16()),
              TextF(
                hint: Strings.note,
                curFocusNode: _fnNote,
                nextFocusNode: _fnBuyer,
                controller: _conNote,
                textInputAction: TextInputAction.next,
              ),
              TextF(
                hint: Strings.buyerName,
                curFocusNode: _fnBuyer,
                controller: _conBuyer,
                textInputAction: TextInputAction.next,
                validator: (value) => value.isEmpty ? Strings.errorEmpty : null,
              ),
              DropDown(
                hint: Strings.status,
                value: _selectedStatus,
                items: Strings.listStatus?.map((item) {
                  return DropdownMenuItem(
                    child: Text(item, style: TextStyles.text),
                    value: item,
                  );
                })?.toList(),
                onChanged: (value) {
                  _selectedStatus = value;
                },
              ),
              SizedBox(
                height: context.dp16(),
              ),
              Button(
                title: Strings.save,
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    if (_listSelectedProduct.isNotEmpty) {
                      for (var selected in _listSelectedProduct) {
                        logs(
                            "qty ${selected.textEditingController.text} - productName ${selected.productName}");
                      }
                    } else {
                      Strings.pleaseSelectProduct.toToastError();
                    }

                    var _params = {
                      "transactionNumber": _transactionNumber,
                      "note": _conNote.text,
                      "buyer": _conBuyer.text,
                      "status": _selectedStatus,
                      "listProduct": _listSelectedProduct
                    };
                    _addSaleBloc.addSale(_params);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  _listItem(int index) {
    if (_listSelectedProduct[index].textEditingController.text == "0")
      _listSelectedProduct[index].textEditingController.text = "1";
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                flex: 5,
                child: Text(
                  _listSelectedProduct[index].productName,
                  style: TextStyles.textBold,
                )),
            Text(
              "@${_listSelectedProduct[index].sellingPrice.toString().toCurrency()}",
              style: TextStyles.text,
            ),
            QuantityPicker(
                focusNode: FocusNode(),
                textEditingController:
                    _listSelectedProduct[index].textEditingController,
                onChanged: (value) async {
                  await _minus(value, index);
                  _plus(value, index);
                  _updateTotal();
                })
          ],
        ),
        Divider()
      ],
    );
  }

  _updateTotal() {
    _totalPrice = 0;
    for (var item in _listSelectedProduct) {
      int _qty = item.textEditingController.text.toInt();
      int _totalPerProduct = _qty * item.sellingPrice;
      setState(() {
        _totalPrice += _totalPerProduct;
      });
    }
  }

  _minus(String value, int index) async {
    if (value == "0") {
      var _isRemove = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          // false = user must tap button, true = tap outside dialog
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: Text(
                Strings.delete,
                style: TextStyles.textBold,
              ),
              content: RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: Strings.askDelete,
                    style: TextStyles.text,
                  ),
                  TextSpan(
                      text: " ${_listSelectedProduct[index].productName} ",
                      style: TextStyles.textBold),
                  TextSpan(
                    text: Strings.questionMark,
                    style: TextStyles.text,
                  )
                ]),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    Strings.cancel,
                    style: TextStyles.textHint,
                  ),
                  onPressed: () {
                    Navigator.pop(dialogContext, false); // Dismiss alert dialog
                  },
                ),
                FlatButton(
                  child: Text(
                    Strings.delete,
                    style: TextStyles.text.copyWith(color: Palette.red),
                  ),
                  onPressed: () {
                    // _deleteProductBloc.deleteProduct(_listProduct[index].id);
                    // _getListProduct();
                    Navigator.pop(dialogContext, true); // Dismiss alert dialog
                  },
                ),
              ],
            );
          });
      if (_isRemove) {
        // delete from list product
        setState(() {
          _listProduct.forEach((element) {
            if (element.id == _listSelectedProduct[index].id)
              element.isSelected = false;
          });
          _listSelectedProduct.removeAt(index);
        });
      } else {
        //reset to 1 if cancel
        _listSelectedProduct[index].textEditingController.text = "1";
      }

      // Update total when item removed
      _updateTotal();
    }
  }

  _plus(String value, int index) {
    var _qty = value.toInt();
    if (_qty > _listSelectedProduct[index].qty) {
      _listSelectedProduct[index].textEditingController.text =
          _listSelectedProduct[index].qty.toString();
      Strings.maxQty.toToastError();
    }
  }
}
