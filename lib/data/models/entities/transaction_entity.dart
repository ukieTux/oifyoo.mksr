class TransactionEntity {
  final int id;
  final String transactionNumber;
  final int idProduct;
  final int qty;
  final int productPrice;
  final String type;
  final String status;
  final String note;
  final String buyer;
  final String createdAt;
  final String updatedAt;

  TransactionEntity({this.id,
    this.transactionNumber,
    this.idProduct,
    this.qty,
    this.productPrice,
    this.type,
    this.status,
    this.note,
    this.buyer,
    this.createdAt,
    this.updatedAt});
}
