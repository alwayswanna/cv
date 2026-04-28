class PersonalData {
  final String personalData;
  final List<String> skills;
  final List<WorkExperience> workExperience;
  final SocialLinks socialLinks;
  final MainInfo mainInfo;
  final String lastUpdated;

  PersonalData(
      {required this.personalData,
      required this.skills,
      required this.workExperience,
      required this.socialLinks,
      required this.mainInfo,
      required this.lastUpdated});

  PersonalData.fromJson(Map<String, dynamic> json)
      : personalData = json['personal-data'],
        skills = List<String>.from(json['skills']),
        mainInfo = MainInfo.fromJson(json['mainInfo']),
        socialLinks = SocialLinks.fromJson(json['social-links']),
        lastUpdated = json['last-updated'],
        workExperience = List<dynamic>.from(json['work-experience'])
            .map((key) => WorkExperience.fromJson(key))
            .toList();
}

class WorkExperience {
  final String company;
  final String period;
  final String position;
  final List<Project> projects;

  WorkExperience(
      {required this.company,
      required this.period,
      required this.position,
      required this.projects});

  WorkExperience.fromJson(Map<String, dynamic> json)
      : company = json['company'],
        period = json['period'],
        position = json['position'],
        projects = List<dynamic>.from(json['projects'])
            .map((p) => Project.fromJson(p))
            .toList();
}

class Project {
  final String name;
  final String description;
  final String period;
  final List<String> skills;
  final List<String> responsibilities;

  Project(
      {required this.name,
      required this.description,
      required this.period,
      required this.skills,
      required this.responsibilities});

  Project.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        description = json['description'],
        period = json['period'],
        skills = List<String>.from(json['skills']),
        responsibilities = List<String>.from(json['responsibilities']);
}

class SocialLinks {
  final String facebook;
  final String linkedIn;
  final String habrCareer;
  final String github;
  final String email;

  SocialLinks(
      {required this.facebook,
      required this.linkedIn,
      required this.habrCareer,
      required this.github,
      required this.email});

  SocialLinks.fromJson(Map<String, dynamic> json)
      : facebook = json['facebook'],
        linkedIn = json['linkedIn'],
        habrCareer = json['habrCareer'],
        github = json['github'],
        email = json['email'];
}

class MainInfo {
  final String firstName;
  final String lastName;
  final String position;
  final String birthDate;
  final String currentLocation;
  final String education;
  final String addition;
  final String photoLink;
  final String? photoFallbackLink;

  MainInfo(
      {required this.birthDate,
      required this.firstName,
      required this.lastName,
      required this.position,
      required this.currentLocation,
      required this.education,
      required this.addition,
      required this.photoLink,
      this.photoFallbackLink});

  MainInfo.fromJson(Map<String, dynamic> json)
      : firstName = json['firstName'],
        lastName = json['lastName'],
        position = json['position'],
        birthDate = json['birthDate'],
        education = json['education'],
        currentLocation = json['currentLocation'],
        addition = json['addition'],
        photoLink = json['photoLink'],
        photoFallbackLink = (json['photoFallbackLink'] as String?)?.isNotEmpty == true
            ? json['photoFallbackLink']
            : null;
}
