enum BidStatus { pending, accepted, rejected }

class BidModel {
  final String id;
  final String projectId;
  final String contractorId;
  final String contractorName;
  final double amount;
  final int durationDays;
  final String comment;
  final BidStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BidModel({
    required this.id,
    required this.projectId,
    required this.contractorId,
    required this.contractorName,
    required this.amount,
    required this.durationDays,
    required this.comment,
    this.status = BidStatus.pending,
    required this.createdAt,
    this.updatedAt,
  });

  factory BidModel.fromJson(Map<String, dynamic> json) {
    return BidModel(
      id: json['id'],
      projectId: json['projectId'],
      contractorId: json['contractorId'],
      contractorName: json['contractorName'],
      amount: json['amount'].toDouble(),
      durationDays: json['durationDays'],
      comment: json['comment'],
      status: BidStatus.values.firstWhere(
        (e) => e.toString() == 'BidStatus.${json['status']}',
        orElse: () => BidStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'contractorId': contractorId,
      'contractorName': contractorName,
      'amount': amount,
      'durationDays': durationDays,
      'comment': comment,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
