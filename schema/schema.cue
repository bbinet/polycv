package polycv

// ============================================================================
// Utility Types
// ============================================================================

#Date:      string | int | null
#ExactDate: string | int | "present" | null

#SocialNetwork: {
	// Network name; must match a key in the template's profiles-config
	// (e.g. "LinkedIn", "GitHub").
	network: string
	// Handle appended to the network's URL base (e.g. "janedoe").
	username: string
}

// ============================================================================
// Entry Types
// ============================================================================

// A timeline or list entry, reused by experience, education, awards,
// volunteering and courses. Not all fields apply to every section.
#Entry: {
	// Primary title (award/course name). Alias of company for list sections.
	name?: string
	// Organisation or employer (experience). Alias: degree for education.
	company?: string
	// Job title or role, shown after the company.
	position?: string
	// Short subtitle under the title. Alias: institution for education.
	summary?: string
	// Place (city, country) shown on the right.
	location?: string
	// Start date, "YYYY-MM" or "YYYY".
	start_date?: #Date
	// End date, "YYYY-MM", "YYYY" or "present".
	end_date?: #ExactDate
	// Single date, alternative to start_date/end_date (awards, courses).
	date?: #Date
	// Bullet points; supports *bold* and _italic_ inline markup.
	highlights?: [...string]

	...
}

#PublicationEntry: {
	// Publication title.
	title: string
	// List of author names.
	authors?: [...string]
	// Short description or venue note.
	summary?: string
	// Digital Object Identifier; rendered as a doi.org link.
	doi?: string
	// Direct URL to the publication.
	url?: string
	// Journal or conference name.
	journal?: string
	// Publication date.
	date?: #Date
	...
}

#SkillEntry: {
	// Skill group heading (e.g. "Languages").
	group: string
	// Skills: a single string, or a list rendered one per line.
	items: string | [...string]
	...
}

// ============================================================================
// CV Schema
// ============================================================================

#CV: {
	// Full name, shown large in the header.
	name?: string
	// Tagline under the name.
	headline?: string
	// Location line (city, country).
	location?: string
	// Tag badges shown in the header.
	keywords?: [...string]
	// Email address; a single string or a list of lines.
	email?: string | [...string]
	// Phone number; a single string or a list of lines.
	phone?: string | [...string]
	// Postal address; a single string or a list of lines.
	address?: string | [...string]
	// Summary / profile paragraph.
	summary?: string
	// Motivation paragraph (cover-letter style intro).
	motivation?: string
	// Personal values, one bullet each.
	values?: [...string]
	// Hobbies / interests, one bullet each.
	hobbies?: [...string]
	// References text, or a list of bullets.
	references?: string | [...string]
	// Social profiles (network + username).
	profiles?: [...#SocialNetwork]
	// Skill groups.
	skills?: [...#SkillEntry]
	// Professional experience entries.
	experience?: [...#Entry]
	// Education entries.
	education?: [...#Entry]
	// Honours and awards.
	awards?: [...#Entry]
	// Volunteering and community involvement entries.
	volunteering?: [...#Entry]
	// Courses and certifications.
	courses?: [...#Entry]
	// Publications.
	publications?: [...#PublicationEntry]
}

// Section keys usable in sidebar-sections / main-sections (either column).
#SectionName: "photo" | "contact" | "skills" | "values" | "hobbies" |
	"references" | "publications" | "summary" | "motivation" |
	"experience" | "education" | "awards" | "volunteering" | "courses"

// Layout/config block; consumed by the template, not part of the CV data.
#CvMeta: {
	// Path to the profile photo, relative to the .typ file.
	photo?: string
	// Language for section titles and month names.
	locale?: "en" | "fr"
	// Full-width header band layout (photo on its left).
	"header-band"?: bool
	// With header-band, render the summary inside the header.
	"header-band-summary"?: bool
	// With header-band, keep the contact line in the band (false = sidebar).
	"header-band-contact"?: bool
	// Two-column ATS-friendly header layout.
	"ats-split"?: bool
	// Company + location/dates on the title line, position below.
	"entry-inline-meta"?: bool
	// Show the dots + vertical line on experience/education entries.
	"show-timeline"?: bool
	// Number of right-aligned lines for keyword badges (0 = one per line).
	"keywords-lines"?: int & >=0
	// Ordered sidebar section keys.
	"sidebar-sections"?: [...#SectionName]
	// Ordered main-column section keys.
	"main-sections"?: [...#SectionName]
	// Override section display titles, keyed by section name.
	"section-titles"?: {[#SectionName]: string}
	// Override section FontAwesome icons, keyed by section name.
	"section-icons"?: {[#SectionName]: string}
}

#CVSchema: {
	// Path (relative to this file) of a parent CV to deep-merge over.
	inherit?: string
	cv:       #CV
	meta?:    #CvMeta
}

// ============================================================================
// Letter Schema
// ============================================================================

#Sender: {
	// Sender's full name.
	name: string
	// Sender's phone number.
	phone?: string
	// Sender's email address.
	email?: string
	// LinkedIn handle.
	linkedin?: string
	// GitHub handle.
	github?: string
	// Sender's postal address.
	address?: string
}

#Recipient: {
	// Recipient's name.
	name?: string
	// Recipient's job title.
	title?: string
	// Recipient's company.
	company?: string
	// Recipient's postal address.
	address?: string
}

#BodyParagraph: {
	// One letter paragraph; supports inline markup.
	paragraph: string
}

#Content: {
	// Subject line, shown as "Re: ...".
	subject?: string
	// Opening salutation.
	salutation?: string
	// Closing phrase before the signature.
	closing?: string
	// Letter body paragraphs.
	body?: [...#BodyParagraph]
}

#Metadata: {
	// Letter date; a display string or "auto" for today.
	date?: string | "auto"
}

#Letter: {
	// Sender block.
	sender: #Sender
	// Recipient block.
	recipient?: #Recipient
	// Letter content (subject, salutation, body, closing).
	content: #Content
	// Letter metadata (date).
	metadata?: #Metadata
}

#LetterSchema: {
	// Path (relative to this file) of a parent letter to deep-merge over.
	inherit?: string
	letter:   #Letter
}

// ============================================================================
// Unified Schema (for JSON export)
// ============================================================================

#UnifiedSchema: {
	// Path (relative to this file) of a parent to deep-merge over.
	inherit?: string
	// CV data.
	cv?: #CV
	// Layout / configuration block.
	meta?: #CvMeta
	// Cover-letter data.
	letter?: #Letter
}
