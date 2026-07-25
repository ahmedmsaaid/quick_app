class CmsSectionDto {
  final String? id;
  final String? titleAr;
  final String? contentAr;
  final String? titleEn;
  final String? contentEn;
  final String? titleTr;
  final String? contentTr;
  final String? subTitleAr;
  final String? subTitleEn;
  final String? subTitleTr;

  CmsSectionDto({
    this.id,
    this.titleAr,
    this.contentAr,
    this.titleEn,
    this.contentEn,
    this.titleTr,
    this.contentTr,
    this.subTitleAr,
    this.subTitleEn,
    this.subTitleTr,
  });

  factory CmsSectionDto.fromJson(Map<String, dynamic> json) {
    return CmsSectionDto(
      id: json['id'] as String?,
      titleAr: json['titleAr'] as String? ?? json['title'] as String?,
      contentAr: json['contentAr'] as String? ?? json['content'] as String?,
      titleEn: json['titleEn'] as String?,
      contentEn: json['contentEn'] as String?,
      titleTr: json['titleTr'] as String?,
      contentTr: json['contentTr'] as String?,
      subTitleAr: json['subTitleAr'] as String?,
      subTitleEn: json['subTitleEn'] as String?,
      subTitleTr: json['subTitleTr'] as String?,
    );
  }
}

class ContactUsFieldDto {
  final String? id;
  final int? type;
  final String? url;

  ContactUsFieldDto({
    this.id,
    this.type,
    this.url,
  });

  factory ContactUsFieldDto.fromJson(Map<String, dynamic> json) {
    return ContactUsFieldDto(
      id: json['id'] as String?,
      type: json['type'] as int?,
      url: json['url'] as String? ?? json['value'] as String?,
    );
  }
}

class CmsPolicyResponse {
  final int? id;
  final bool? active;
  final List<CmsSectionDto>? policySections;

  CmsPolicyResponse({
    this.id,
    this.active,
    this.policySections,
  });

  factory CmsPolicyResponse.fromJson(Map<String, dynamic> json) {
    return CmsPolicyResponse(
      id: json['id'] as int?,
      active: json['active'] as bool?,
      policySections: (json['policySections'] as List?)
          ?.map((e) => CmsSectionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CmsAboutUsResponse {
  final int? id;
  final bool? active;
  final List<CmsSectionDto>? aboutUsSections;

  CmsAboutUsResponse({
    this.id,
    this.active,
    this.aboutUsSections,
  });

  factory CmsAboutUsResponse.fromJson(Map<String, dynamic> json) {
    return CmsAboutUsResponse(
      id: json['id'] as int?,
      active: json['active'] as bool?,
      aboutUsSections: (json['aboutUsSections'] as List?)
          ?.map((e) => CmsSectionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CmsContactUsResponse {
  final int? id;
  final bool? active;
  final List<ContactUsFieldDto>? contactUsFields;

  CmsContactUsResponse({
    this.id,
    this.active,
    this.contactUsFields,
  });

  factory CmsContactUsResponse.fromJson(Map<String, dynamic> json) {
    return CmsContactUsResponse(
      id: json['id'] as int?,
      active: json['active'] as bool?,
      contactUsFields: (json['contactUsFields'] as List?)
          ?.map((e) => ContactUsFieldDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
