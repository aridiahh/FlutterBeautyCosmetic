class SettingBunga {
  SettingBunga({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool? success;
  static const String successKey = "success";

  final String? message;
  static const String messageKey = "message";

  final Data? data;
  static const String dataKey = "data";

  SettingBunga copyWith({
    bool? success,
    String? message,
    Data? data,
  }) {
    return SettingBunga(
      success: success ?? this.success,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }

  factory SettingBunga.fromJson(Map<String, dynamic> json) {
    return SettingBunga(
      success: json["success"],
      message: json["message"],
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
      };

  @override
  String toString() {
    return "$success, $message, $data, ";
  }
}

class Data {
  Data({
    required this.activebunga,
    required this.settingbungas,
  });

  final Activebunga? activebunga;
  static const String activebungaKey = "activebunga";

  final List<Activebunga> settingbungas;
  static const String settingbungasKey = "settingbungas";

  Data copyWith({
    Activebunga? activebunga,
    List<Activebunga>? settingbungas,
  }) {
    return Data(
      activebunga: activebunga ?? this.activebunga,
      settingbungas: settingbungas ?? this.settingbungas,
    );
  }

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      activebunga: json["activebunga"] == null
          ? null
          : Activebunga.fromJson(json["activebunga"]),
      settingbungas: json["settingbungas"] == null
          ? []
          : List<Activebunga>.from(
              json["settingbungas"]!.map((x) => Activebunga.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "activebunga": activebunga?.toJson(),
        "settingbungas": settingbungas.map((x) => x?.toJson()).toList(),
      };

  @override
  String toString() {
    return "$activebunga, $settingbungas, ";
  }
}

class Activebunga {
  Activebunga({
    required this.id,
    required this.persen,
    required this.isaktif,
  });

  final int? id;
  static const String idKey = "id";

  final double? persen;
  static const String persenKey = "persen";

  final int? isaktif;
  static const String isaktifKey = "isaktif";

  Activebunga copyWith({
    int? id,
    double? persen,
    int? isaktif,
  }) {
    return Activebunga(
      id: id ?? this.id,
      persen: persen ?? this.persen,
      isaktif: isaktif ?? this.isaktif,
    );
  }

  factory Activebunga.fromJson(Map<String, dynamic> json) {
    return Activebunga(
      id: json["id"],
      persen: double.parse(json["persen"].toString()),
      isaktif: json["isaktif"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "persen": persen,
        "isaktif": isaktif,
      };

  @override
  String toString() {
    return "$id, $persen, $isaktif, ";
  }
}
