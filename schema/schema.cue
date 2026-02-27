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

#CVSchema: {
	cv: #CV
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
	letter?: #Letter
}
