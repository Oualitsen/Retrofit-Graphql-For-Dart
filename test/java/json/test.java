
public class UserInput {
	private String id;
	private String name;
	private String middleName;
	private Integer dateOfBirth;
	private Double price;
	private Gender gender;
	public UserInput() {
	}


	private UserInput(final String id, final String name, final String middleName, final Integer dateOfBirth, final Double price, final Gender gender) {
		this.id = id;
		this.name = name;
		this.middleName = middleName;
		this.dateOfBirth = dateOfBirth;
		this.price = price;
		this.gender = gender;
	}


	public static Builder builder() {
		return new Builder();
	}


	public static class Builder {
		private String id;
		private String name;
		private String middleName;
		private Integer dateOfBirth;
		private Double price;
		private Gender gender;

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
		public Builder price(final Double price) {
			this.price = price;
			return this;
		}
		public Builder gender(final Gender gender) {
			this.gender = gender;
			return this;
		}

		public UserInput build() {
			return new UserInput(id, name, middleName, dateOfBirth, price, gender);
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
	public Double getPrice() { 
		return price;
	}
	public Gender getGender() { 
		return gender;
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
	public void setPrice(final Double price) {
		this.price = price;
	}
	public void setGender(final Gender gender) {
		this.gender = gender;
	}

	public java.util.Map<String, Object> toJson() {
		java.util.Map<String, Object> map = new java.util.HashMap<>();
		map.put("id", id);
		map.put("name", name);
		map.put("middleName", middleName);
		map.put("dateOfBirth", dateOfBirth);
		map.put("price", price);
		map.put("gender", java.util.Optional.ofNullable(gender).map((e) -> e.toJson()).orElse(null));
		return map;
	}


	static UserInput fromJson(Map<String, Object> json) {
		UserInput value = new UserInput();
		value.id = json.get("id");
		value.name = json.get("name");
		value.middleName = json.get("middleName");
		value.dateOfBirth = json.get("dateOfBirth");
		value.price = json.get("price");
		value.gender = json.get("gender");
		return value;
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


	static CityInput fromJson(Map<String, Object> json) {
		CityInput value = new CityInput();
		value.name = json.get("name");
		return value;
	}

}

