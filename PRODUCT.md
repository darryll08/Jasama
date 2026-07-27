# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

Jasama serves Indonesian users aged 18 and above who need help completing local or digital tasks. Its initial audience is students, young adults, freelancers, and early-career workers, while remaining inclusive and appropriate for the general public, families, professionals, and small businesses.

- **Pemesan (customer):** Quickly find a trustworthy person who can complete a local or digital task.
- **Mitra (service provider):** Offer skills or availability, receive orders, communicate with customers, complete work, and build a trusted reputation.
- **Administrator:** Verify providers, moderate listings, monitor orders, handle reports, and resolve disputes.

## Product Purpose

Jasama is an Indonesian service marketplace connecting customers with trusted providers for practical local errands and digital work.

Customers can discover a suitable Jasa or publish a Permintaan, assess the Mitra through profiles, portfolios, prices, verification, and reviews, communicate and agree on the work, place a recorded Pesanan, track progress, receive proof or a digital delivery, and review the result. Mitra can publish services, respond with custom offers, complete orders, and build a reputation.

Success means helping users complete small, real needs with less friction and greater confidence while enabling Mitra to earn through their skills and availability.

## Positioning

Jasama combines everyday local errands and digital services in one marketplace built for Indonesian users, local payment methods, and small practical tasks—not only formal freelance projects. Trust comes from transparent pricing, verification, reviews, clear communication, and recorded orders.

The product is initially approachable for younger adults without becoming youth-exclusive.

## Operating Context

Local services may include buying and delivering items, package pickup, queueing, printing and delivering documents, event assistance, light moving assistance, and everyday errands.

Digital services may include presentation and graphic design, video editing, UI/UX and Figma work, tutoring, proofreading, programming assistance, debugging, data analysis consultation, and digital administration.

Core workflows include:

1. Browse or search Jasa and filter Mitra.
2. Review service details, provider profiles, portfolios, prices, verification, and reviews.
3. Order an existing service or create a custom Permintaan.
4. Chat, clarify requirements, and receive or create a custom offer.
5. Place and track a Pesanan.
6. Submit work, digital delivery, or proof of completion.
7. Rate, review, save, and rebook a trusted Mitra.

Administrators verify Mitra, moderate listings, monitor orders, handle reports, and support basic dispute resolution.

## Capabilities and Constraints

Required product capabilities:

- Public homepage and authentication.
- Pemesan, Mitra, and administrator roles.
- Mitra profiles, portfolios, verification, service listings, and categories.
- Search, filters, service details, pricing, and reviews.
- Custom Permintaan, simple messaging, and custom offers.
- Pesanan workflow, status tracking, proof of completion, and digital delivery.
- Ratings, reviews, favorites, and rebooking.
- Pemesan, Mitra, and administrator dashboards.
- Reports and basic dispute handling.
- Loading, empty, success, and error states on important pages.

Technical direction:

- Next.js App Router, TypeScript, and Tailwind CSS.
- Supabase PostgreSQL, Auth, and Storage.
- GitHub and Vercel deployment.
- Midtrans integration later.
- Responsive, accessible components with mobile usability as a first-class requirement.
- Avoid unnecessary paid dependencies.

Current scope exclusions:

- AI product features.
- Paid marketing integrations.
- Native mobile applications.
- Internal wallet.
- GPS tracking.
- Internal video calls.
- Complex bidding.

Safety restrictions:

Jasama may support tutoring, consultation, proofreading, debugging, design, delivery, errands, and project assistance. It must not promote active exam assistance, impersonation, plagiarism, fabricated documents, fraud, manipulated research data, submitting another person's work as the customer's own, or illegal, dangerous, or abusive services.

## Brand Commitments

- The product name is **Jasama**.
- Primary language is natural Indonesian: neither excessively formal, childish, slang-heavy, corporate, nor robotic.
- Brand personality is trustworthy, practical, warm, inclusive, transparent, modern, calm, and helpful.
- The interface must feel like a trustworthy Indonesian marketplace rather than a generic SaaS template.
- Information hierarchy and navigation must be clear and practical.
- Mobile-first layouts must also work properly on desktop and tablet.
- Use purposeful whitespace, consistent spacing, accessible contrast, visible focus states, a consistent icon library, and realistic marketplace content.
- Avoid purple-to-blue AI gradients, pervasive glassmorphism, excessive rounded or nested cards, generic SaaS dashboards, decorative floating blobs, excessive animation, emoji interface icons, low-contrast gray text, oversized marketing headlines, desktop-only layouts, excessive pills or badges, and generic AI-generated copy.

Core terminology:

- Customer: **Pemesan**
- Service provider: **Mitra**
- Service listing: **Jasa**
- Custom task request: **Permintaan**
- Order: **Pesanan**
- Become a provider: **Jadi Mitra**
- Browse services: **Jelajahi Jasa**
- Post a task: **Buat Permintaan**

## Evidence on Hand

The repository currently contains no application implementation, logo, photography, marketplace data, testimonials, customer claims, benchmarks, case studies, pricing evidence, or other proof assets. Future work must use clearly labeled realistic sample content where needed and must not fabricate customer evidence or performance claims.

## Product Principles

1. **Trust is operational:** Make identity, pricing, expectations, order history, proof, reviews, reporting, and dispute paths clear.
2. **Practical tasks deserve a simple path:** Keep discovery, requests, offers, ordering, delivery, and rebooking direct.
3. **Local and digital belong together:** Support both service types coherently without forcing either into an unsuitable workflow.
4. **Indonesian by default, inclusive by design:** Use natural local language and context without narrowing the product to one generation or social group.
5. **Safety before growth:** Prevent prohibited services and preserve moderation, verification, reporting, and accountability.

## Accessibility & Inclusion

- Use semantic HTML and support complete keyboard navigation.
- Provide visible focus states and sufficient color contrast.
- Label every form control and provide descriptive errors.
- Never communicate status through color alone.
- Use touch targets suitable for mobile.
- Keep language and interaction patterns appropriate for adults across ages, professions, and levels of digital familiarity.
