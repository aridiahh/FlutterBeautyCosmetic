class InsertTransaksiFailureResponse {
    bool success;
    String message;
    Data data;

    InsertTransaksiFailureResponse({
        required this.success,
        required this.message,
        required this.data,
    });

}

class Data {
    String error;

    Data({
        required this.error,
    });

}
