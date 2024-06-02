class MasterTransaksiResponse {
  bool? success;
  String? message;
  Data? data;

  MasterTransaksiResponse({this.success, this.message, this.data});

  MasterTransaksiResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<Jenistransaksi>? jenistransaksi;

  Data({this.jenistransaksi});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['jenistransaksi'] != null) {
      jenistransaksi = <Jenistransaksi>[];
      json['jenistransaksi'].forEach((v) {
        jenistransaksi!.add(new Jenistransaksi.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.jenistransaksi != null) {
      data['jenistransaksi'] =
          this.jenistransaksi!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Jenistransaksi {
  int? id;
  String? trxName;
  int? trxMultiply;

  Jenistransaksi({this.id, this.trxName, this.trxMultiply});

  Jenistransaksi.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    trxName = json['trx_name'];
    trxMultiply = json['trx_multiply'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['trx_name'] = this.trxName;
    data['trx_multiply'] = this.trxMultiply;
    return data;
  }
}
