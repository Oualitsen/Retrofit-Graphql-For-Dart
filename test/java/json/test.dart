class User {

	final String? id;
	final String name;
	final String? middleName;
	final int? dateOfBirth;

	User({this.id, required this.name, this.middleName, this.dateOfBirth});

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'name': name,
			'middleName': middleName,
			'dateOfBirth': dateOfBirth
		};
	}

	static User fromJson(Map<String, dynamic> json) {
		return User(
			id: json['id'] as String?,
			name: json['name'] as String,
			middleName: json['middleName'] as String?,
			dateOfBirth: json['dateOfBirth'] as int?
		);
	}

}

enum Gender {
	male, female;
	String toJson() {
		switch(this) {
			case male: return "male";
			case female: return "female";
		}
	}
	static Gender fromJson(String value) {
		switch(value) {
			case "male": return male;
			case "female": return female;
			default: throw ArgumentError("Invalid Gender: $value");
		}
	}
}

class City {

	final String name;

	City({required this.name});

	Map<String, dynamic> toJson() {
		return {
			'name': name
		};
	}

	static City fromJson(Map<String, dynamic> json) {
		return City(
			name: json['name'] as String
		);
	}

}

