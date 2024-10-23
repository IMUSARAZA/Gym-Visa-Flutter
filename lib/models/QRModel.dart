class QR {
  late String userID;
  late String gymName;
  late String time;
  late String QRID;
  late String gymSubscription;
  late String gymAddress;

  QR(
      {required this.userID,
      required this.gymName,
      required this.time,
      required this.QRID,
      required this.gymSubscription,
      required this.gymAddress});

  factory QR.fromJson(Map<String, dynamic> json) {
    return QR(
      userID: json['UserID'] ?? '',
      gymName: json['gymName'] ?? '',
      time: json['Time'] ?? '',
      QRID: json['QRID'] ?? '',
      gymSubscription: json['gymSubscription'] ?? '',
      gymAddress: json['gymAddress'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UserID': userID,
      'gymName': gymName,
      'Time': time,
      'QRID': QRID,
      'gymSubscription': gymSubscription,
      'gymAddress': gymAddress,
    };
  }

  QR copyWith({
    String? userID,
    String? gymName,
    String? time,
    String? QRID,
    String? gymSubscription,
    String? gymAddress,
  }) {
    return QR(
      userID: userID ?? this.userID,
      gymName: gymName ?? this.gymName,
      time: time ?? this.time,
      QRID: QRID ?? this.QRID,
      gymSubscription: gymSubscription ?? this.gymSubscription,
      gymAddress: gymAddress ?? this.gymAddress,
    );
  }
}
