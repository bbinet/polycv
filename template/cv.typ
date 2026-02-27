// typst compile --root . template/cv.typ
#import "/src/lib.typ": cv

#let cd = toml("cv.toml").cv // cv data

#show: cv.with(
  name: cd.name,
  headline: cd.at("headline", default: none),
  location: cd.at("location", default: none),
  keywords: cd.at("keywords", default: none),
  email: cd.at("email", default: none),
  phone: cd.at("phone", default: none),
  address: cd.at("address", default: none),
  profiles: cd.at("profiles", default: none),
  summary: cd.at("summary", default: none),
  motivation: cd.at("motivation", default: none),
  experience: cd.at("experience", default: none),
  education: cd.at("education", default: none),
  awards: cd.at("awards", default: none),
  courses: cd.at("courses", default: none),
  skills: cd.at("skills", default: none),
  values: cd.at("values", default: none),
  hobbies: cd.at("hobbies", default: none),
  references: cd.at("references", default: none),
  publications: cd.at("publications", default: none),
  // sidebar-sections: ("contact", "skills", "values", "hobbies", "references", "publications"),
  // main-sections: ("summary", "motivation", "experience", "education", "awards", "courses"),
  // section-icons: (experience: "briefcase", awards: "medal"),
  // section-titles: (awards: "PRIZES & RECOGNITION"),
)
