
public class UserInput {
	private String id;
	private String name;
	private String middleName;
	private Integer dateOfBirth;
	private Gender gender;
	private Gender gender2;
	private java.util.List<String> names;
	private java.util.List<java.util.List<Gender>> deepGender;
	private java.util.List<Gender> genders1;
	private java.util.List<Gender> genders2;
	private java.util.List<Gender> genders3;
	private CityInput city;
	private CityInput city2;
	public UserInput() {
	}


	private UserInput(final String id, final String name, final String middleName, final Integer dateOfBirth, final Gender gender, final Gender gender2, final java.util.List<String> names, final java.util.List<java.util.List<Gender>> deepGender, final java.util.List<Gender> genders1, final java.util.List<Gender> genders2, final java.util.List<Gender> genders3, final CityInput city, final CityInput city2) {
		this.id = id;
		this.name = name;
		this.middleName = middleName;
		this.dateOfBirth = dateOfBirth;
		this.gender = gender;
		this.gender2 = gender2;
		this.names = names;
		this.deepGender = deepGender;
		this.genders1 = genders1;
		this.genders2 = genders2;
		this.genders3 = genders3;
		this.city = city;
		this.city2 = city2;
	}


	public static Builder builder() {
		return new Builder();
	}


	public static class Builder {
		private String id;
		private String name;
		private String middleName;
		private Integer dateOfBirth;
		private Gender gender;
		private Gender gender2;
		private java.util.List<String> names;
		private java.util.List<java.util.List<Gender>> deepGender;
		private java.util.List<Gender> genders1;
		private java.util.List<Gender> genders2;
		private java.util.List<Gender> genders3;
		private CityInput city;
		private CityInput city2;

		public Builder id(final String id) {
			this.id = id;
			return this;
		}
		public Builder name(final String name) {
			this.name = name;
			return this;
		}
		public Builder middleName(final String middleName) {
			this.middleName = middleName;
			return this;
		}
		public Builder dateOfBirth(final Integer dateOfBirth) {
			this.dateOfBirth = dateOfBirth;
			return this;
		}
		public Builder gender(final Gender gender) {
			this.gender = gender;
			return this;
		}
		public Builder gender2(final Gender gender2) {
			this.gender2 = gender2;
			return this;
		}
		public Builder names(final java.util.List<String> names) {
			this.names = names;
			return this;
		}
		public Builder deepGender(final java.util.List<java.util.List<Gender>> deepGender) {
			this.deepGender = deepGender;
			return this;
		}
		public Builder genders1(final java.util.List<Gender> genders1) {
			this.genders1 = genders1;
			return this;
		}
		public Builder genders2(final java.util.List<Gender> genders2) {
			this.genders2 = genders2;
			return this;
		}
		public Builder genders3(final java.util.List<Gender> genders3) {
			this.genders3 = genders3;
			return this;
		}
		public Builder city(final CityInput city) {
			this.city = city;
			return this;
		}
		public Builder city2(final CityInput city2) {
			this.city2 = city2;
			return this;
		}

		public UserInput build() {
			return new UserInput(id, name, middleName, dateOfBirth, gender, gender2, names, deepGender, genders1, genders2, genders3, city, city2);
		}

	}
          
	public String getId() { 
		return id;
	}
	public String getName() { 
		return name;
	}
	public String getMiddleName() { 
		return middleName;
	}
	public Integer getDateOfBirth() { 
		return dateOfBirth;
	}
	public Gender getGender() { 
		return gender;
	}
	public Gender getGender2() { 
		return gender2;
	}
	public java.util.List<String> getNames() { 
		return names;
	}
	public java.util.List<java.util.List<Gender>> getDeepGender() { 
		return deepGender;
	}
	public java.util.List<Gender> getGenders1() { 
		return genders1;
	}
	public java.util.List<Gender> getGenders2() { 
		return genders2;
	}
	public java.util.List<Gender> getGenders3() { 
		return genders3;
	}
	public CityInput getCity() { 
		return city;
	}
	public CityInput getCity2() { 
		return city2;
	}

	public void setId(final String id) {
		this.id = id;
	}
	public void setName(final String name) {
		this.name = name;
	}
	public void setMiddleName(final String middleName) {
		this.middleName = middleName;
	}
	public void setDateOfBirth(final Integer dateOfBirth) {
		this.dateOfBirth = dateOfBirth;
	}
	public void setGender(final Gender gender) {
		this.gender = gender;
	}
	public void setGender2(final Gender gender2) {
		this.gender2 = gender2;
	}
	public void setNames(final java.util.List<String> names) {
		this.names = names;
	}
	public void setDeepGender(final java.util.List<java.util.List<Gender>> deepGender) {
		this.deepGender = deepGender;
	}
	public void setGenders1(final java.util.List<Gender> genders1) {
		this.genders1 = genders1;
	}
	public void setGenders2(final java.util.List<Gender> genders2) {
		this.genders2 = genders2;
	}
	public void setGenders3(final java.util.List<Gender> genders3) {
		this.genders3 = genders3;
	}
	public void setCity(final CityInput city) {
		this.city = city;
	}
	public void setCity2(final CityInput city2) {
		this.city2 = city2;
	}

	public java.util.Map<String, Object> toJson() {
		java.util.Map<String, Object> map = new java.util.HashMap<>();
		map.put("id", id);
		map.put("name", name);
		map.put("middleName", middleName);
		map.put("dateOfBirth", dateOfBirth);
		map.put("gender", java.util.Optional.ofNullable(gender).map((e) -> e.toJson()).orElse(null));
		map.put("gender2", gender2.toJson());
		map.put("names", names.stream().map(e0 -> e0).collect(java.util.stream.Collectors.toList()));
		map.put("deepGender", deepGender.stream().map(e0 -> java.util.Optional.ofNullable(e0).map((e) -> e.stream().map(e1 -> java.util.Optional.ofNullable(e1).map((e) -> e.toJson()).orElse(null)).collect(java.util.stream.Collectors.toList())).orElse(null)).collect(java.util.stream.Collectors.toList()));
		map.put("genders1", genders1.stream().map(e0 -> e0.toJson()).collect(java.util.stream.Collectors.toList()));
		map.put("genders2", genders2.stream().map(e0 -> java.util.Optional.ofNullable(e0).map((e) -> e.toJson()).orElse(null)).collect(java.util.stream.Collectors.toList()));
		map.put("genders3", java.util.Optional.ofNullable(genders3).map((e) -> e.stream().map(e0 -> e0.toJson()).collect(java.util.stream.Collectors.toList())).orElse(null));
		map.put("city", java.util.Optional.ofNullable(city).map((e) -> e.toJson()).orElse(null));
		map.put("city2", city2.toJson());
		return map;
	}


	public static UserInput fromJson(java.util.Map<String, Object> json) {
		return new UserInput(
			json.get("id") == null ? null : (String)json.get("id"),
			(String)json.get("name"),
			json.get("middleName") == null ? null : (String)json.get("middleName"),
			json.get("dateOfBirth") == null ? null : ((Number)json.get("dateOfBirth")).intValue(),
			json.get("gender") == null ? null : Gender.fromJson((String)json.get("gender")),
			Gender.fromJson((String)json.get("gender2")),
			 ((java.util.List<Object>)json.get("names")).stream().map(json0 -> (String)json0).collect(java.util.stream.Collectors.toList()),
			 ((java.util.List<Object>)json.get("deepGender")).stream().map(json0 -> json0 == null ? null : ((java.util.List<Object>)json0).stream().map(json01 -> json01 == null ? null : Gender.fromJson((String)json01)).collect(java.util.stream.Collectors.toList())).collect(java.util.stream.Collectors.toList()),
			 ((java.util.List<Object>)json.get("genders1")).stream().map(json0 -> Gender.fromJson((String)json0)).collect(java.util.stream.Collectors.toList()),
			 ((java.util.List<Object>)json.get("genders2")).stream().map(json0 -> json0 == null ? null : Gender.fromJson((String)json0)).collect(java.util.stream.Collectors.toList()),
			json.get("genders3") == null ? null : ((java.util.List<Object>)json.get("genders3")).stream().map(json0 -> Gender.fromJson((String)json0)).collect(java.util.stream.Collectors.toList()),
			json.get("city") == null ? null : CityInput.fromJson((java.util.Map<String, Object>)json.get("city")),
			CityInput.fromJson((java.util.Map<String, Object>)json.get("city2"))
		);
	}

}


public class CityInput {
	private String name;
	public CityInput() {
	}


	private CityInput(final String name) {
		this.name = name;
	}


	public static Builder builder() {
		return new Builder();
	}


	public static class Builder {
		private String name;

		public Builder name(final String name) {
			this.name = name;
			return this;
		}

		public CityInput build() {
			return new CityInput(name);
		}

	}
          
	public String getName() { 
		return name;
	}

	public void setName(final String name) {
		this.name = name;
	}

	public java.util.Map<String, Object> toJson() {
		java.util.Map<String, Object> map = new java.util.HashMap<>();
		map.put("name", name);
		return map;
	}


	public static CityInput fromJson(java.util.Map<String, Object> json) {
		return new CityInput(
			(String)json.get("name")
		);
	}

}

public enum Gender {
	male, female;
	public String toJson() {
		return name();
	}
	public static Gender fromJson(String value) {
		return java.util.Optional.ofNullable(value).map(Gender::valueOf).orElse(null);
	}
}

