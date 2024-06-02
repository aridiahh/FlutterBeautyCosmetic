class InsertTransaksiSuccessResponse {
    bool success;
    String message;
    Data data;
    Req req;

    InsertTransaksiSuccessResponse({
        required this.success,
        required this.message,
        required this.data,
        required this.req,
    });

}

class Data {
    Tabungan tabungan;

    Data({
        required this.tabungan,
    });

}

class Tabungan {
    String anggotaId;
    String trxId;
    String trxNominal;
    int createdByUserid;
    DateTime trxTanggal;
    DateTime updatedAt;
    DateTime createdAt;
    int id;

    Tabungan({
        required this.anggotaId,
        required this.trxId,
        required this.trxNominal,
        required this.createdByUserid,
        required this.trxTanggal,
        required this.updatedAt,
        required this.createdAt,
        required this.id,
    });

}

class Req {
    String anggotaId;
    String trxId;
    String trxNominal;
    int createdByUserid;
    DateTime trxTanggal;

    Req({
        required this.anggotaId,
        required this.trxId,
        required this.trxNominal,
        required this.createdByUserid,
        required this.trxTanggal,
    });

}
