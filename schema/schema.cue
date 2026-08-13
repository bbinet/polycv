package nabcv

// ============================================================================
// Utility Types
// ============================================================================

#Date:      string | int | null
#ExactDate: string | int | "present" | null

#SocialNetwork: {
	network:  string // must match a key in profiles-config
	username: string
}

// ============================================================================
// Entry Types
// ============================================================================

#Entry: {
	name?:       string
	company?:    string
	position?:   string
	summary?:    string
	location?:   string
	start_date?: #Date
	end_date?:   #ExactDate
	date?:       #Date
	highlights?: [...string]

	...
}

#PublicationEntry: {
	title: string
	authors?: [...string]
	summary?: string
	doi?:     string
	url?:     string
	journal?: string
	date?:    #Date
	...
}

#SkillEntry: {
	group: string
	items: string | [...string]
	...
}

// ============================================================================
// CV Schema
// ============================================================================

#CV: {
	name?:     string
	headline?: string
	location?: string
	keywords?: [...string]
	email?: string | [...string]
	phone?: string | [...string]
	address?: string | [...string]
	summary?:    string
	motivation?: string
	values?: [...string]
	hobbies?: [...string]
	references?: string | [...string]
	profiles?: [...#SocialNetwork]
	skills?: [...#SkillEntry]
	experience?: [...#Entry]
	education?: [...#Entry]
	awards?: [...#Entry]
	courses?: [...#Entry]
	publications?: [...#PublicationEntry]
}

// Section keys usable in sidebar-sections / main-sections (either column).
#SectionName: "photo" | "contact" | "skills" | "values" | "hobbies" |
	"references" | "publications" | "summary" | "motivation" |
	"experience" | "education" | "awards" | "courses"

// Layout/config block; consumed by the template, not part of the CV data.
#CvMeta: {
	photo?:               string
	locale?:              "en" | "fr"
	"header-band"?:       bool
	"header-band-summary"?: bool
	"header-band-contact"?: bool
	"ats-split"?:         bool
	"entry-inline-meta"?: bool
	"keywords-lines"?:    int & >=0
	"sidebar-sections"?: [...#SectionName]
	"main-sections"?: [...#SectionName]
}

#CVSchema: {
	cv:    #CV
	meta?: #CvMeta
}

// ============================================================================
// Letter Schema
// ============================================================================

#Sender: {
	name:      string
	phone?:    string
	email?:    string
	linkedin?: string
	github?:   string
	address?:  string
}

#Recipient: {
	name?:    string
	title?:   string
	company?: string
	address?: string
}

#BodyParagraph: {
	paragraph: string
}

#Content: {
	subject?:    string
	salutation?: string
	closing?:    string
	body?: [...#BodyParagraph]
}

#Metadata: {
	date?: string | "auto"
}

#Letter: {
	sender:     #Sender
	recipient?: #Recipient
	content:    #Content
	metadata?:  #Metadata
}

#LetterSchema: {
	letter: #Letter
}

// ============================================================================
// Unified Schema (for JSON export)
// ============================================================================

#UnifiedSchema: {
	cv?:     #CV
	meta?:   #CvMeta
	letter?: #Letter
}
