class VendorDocumentItemModel {
  final String documentType;
  final String documentUrl;

  VendorDocumentItemModel({
    required this.documentType,
    required this.documentUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'document_type': documentType,
      'document_url': documentUrl,
    };
  }
}

class VendorBusinessDetailsRequestModel {
  final String? gstNumber;
  final String? panNumber;
  final String? uscNumber;
  final String? aadhaarNumber;
  final String? msmeNumber;
  final String? govtAuthDocNumber;
  final String? currentBillNumber;
  final List<VendorDocumentItemModel>? documents;

  VendorBusinessDetailsRequestModel({
    this.gstNumber,
    this.panNumber,
    this.uscNumber,
    this.aadhaarNumber,
    this.msmeNumber,
    this.govtAuthDocNumber,
    this.currentBillNumber,
    this.documents,
  });

  Map<String, dynamic> toJson() {
    return {
      if (gstNumber != null) 'gst_number': gstNumber,
      if (panNumber != null) 'pan_number': panNumber,
      if (uscNumber != null) 'usc_number': uscNumber,
      if (aadhaarNumber != null) 'aadhaar_number': aadhaarNumber,
      if (msmeNumber != null) 'msme_number': msmeNumber,
      if (govtAuthDocNumber != null) 'govt_auth_doc_number': govtAuthDocNumber,
      if (currentBillNumber != null) 'current_bill_number': currentBillNumber,
      if (documents != null)
        'documents': documents!.map((e) => e.toJson()).toList(),
    };
  }
}
