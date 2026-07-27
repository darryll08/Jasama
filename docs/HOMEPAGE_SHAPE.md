# Jasama Homepage and Service Discovery Shape

Status: **approved direction; ready for implementation planning**  
Target: public homepage and initial service-discovery experience  
Platform: responsive web, mobile-first  
Visitor mode: **Persuade**, with an embedded discovery task  

## Source-of-Truth Precedence

1. `PRODUCT.md` is the product authority.
2. `DESIGN.md` is the current visual and interaction authority.
3. `docs/HOMEPAGE_SHAPE.md` defines the homepage structure and discovery flow.

This document must not override product truth or the current design system. In production and public-facing claims, fabricated testimonials, claims, statistics, ratings, reviews, prices, partners, rankings, and performance evidence are prohibited. Synthetic data must never be presented as real customer evidence.

## 1. Homepage Objective and Main Decisions

The homepage must help an Indonesian adult understand within seconds that Jasama connects people with trusted help for both local errands and digital work.

The primary audience is a prospective **Pemesan**. **Jadi Mitra** remains visible as an important secondary path without splitting the opening message between two audiences.

The homepage must help a visitor make four decisions:

1. **Can Jasama help with my need?** Show the breadth of local and digital work with concrete examples.
2. **Should I browse or describe the task myself?** Offer both `Jelajahi Jasa` and `Buat Permintaan`.
3. **Can I trust the person and the process?** Explain verification, reviews, recorded orders, safety rules, reporting, and dispute support without unsupported guarantees.
4. **What should I do next?** Let visitors search immediately; do not make them read a long marketing page first.

Success for the homepage:

- A visitor can start a search, open a category, or create a Permintaan from the first viewport.
- Local and digital services feel equally native to Jasama.
- Trust is demonstrated through visible mechanisms rather than slogans.
- A prospective Mitra can find `Jadi Mitra` without competing with the Pemesan journey.

## 2. Page Structure

### Navbar

Keep the public navigation compact and task-oriented.

**Desktop**

- Jasama wordmark.
- `Jelajahi Jasa`
- `Cara Kerja`
- `Jadi Mitra`
- `Masuk`
- `Daftar` as the final emphasized action.

`Kategori` is accessible through `Jelajahi Jasa`. `Keamanan` is explained on the homepage and linked from the footer. `Buat Permintaan` may appear as a compact secondary navigation action when space allows, without competing with `Jelajahi Jasa`.

**Mobile**

- Jasama wordmark.
- Search control.
- `Masuk`.
- Menu button with an accessible label.
- Expanded menu contains the remaining destinations and both main actions, with `Jelajahi Jasa` before `Buat Permintaan` and `Jadi Mitra` after the Pemesan path.

The navbar may become sticky after the visitor leaves the hero. It must not consume excessive vertical space or hide content when the on-screen keyboard opens.

### Hero

The hero is a working entry into discovery, not an oversized empty statement.

**Recommended copy**

> **Butuh bantuan untuk urusan lokal atau pekerjaan digital?**
>
> Temukan Mitra untuk antar barang, desain presentasi, edit video, les, dan kebutuhan praktis lainnya.

**Hero search**

- Label: `Cari jasa`
- Placeholder: `Contoh: edit video, ambil paket, atau les matematika`
- Submit: `Cari`
- Search suggestions distinguish `Jasa`, `Kategori`, and `Mitra`.

**Actions**

- Primary: `Jelajahi Jasa`
- Companion: `Buat Permintaan`
- Secondary role path: `Punya keahlian atau waktu luang? Jadi Mitra`

The first viewport should also show a compact set of concrete entry points such as `Antar & Titip Beli`, `Desain & Presentasi`, `Ambil Paket atau Dokumen`, and `Video & Audio`. These are navigation shortcuts, not decorative pills.

### Homepage Sections

1. **Hero and search**  
   Explain the combined marketplace and enable immediate action.

2. **Kategori utama**  
   Show the approved four local and four digital entry points side by side. Do not label categories “populer” until real usage data supports the claim.

3. **Jasa yang bisa kamu jelajahi**  
   A representative mix of local and digital Jasa. Development and staging may use realistic synthetic records under the demo-data rules below.

4. **Cara menggunakan Jasama**  
   Three direct steps:
   - `Cari Jasa atau buat Permintaan`
   - `Periksa profil dan sepakati detail`
   - `Pantau Pesanan dan beri ulasan`

5. **Kenali Mitra dan mekanisme kepercayaan**  
   Demonstrate what a profile contains: the truthful closed-beta `Profil Mitra diperiksa` state, portfolio, service area, rating count, completed-order reviews, and report action. Explain that the profile review covers contact, completeness, portfolio, and manual onboarding eligibility without government-ID collection. In the same section, explain recorded orders, service restrictions, reporting, and basic dispute support without unsupported guarantees.

6. **Tidak menemukan Jasa yang pas?**  
   Explain custom requests:
   > Ceritakan kebutuhan, waktu, dan anggaranmu. Mitra yang sesuai dapat mengirim penawaran.
   
   Action: `Buat Permintaan`

7. **Jadi Mitra dan panduan ringkas**  
   A concise provider-recruitment section after the customer journey:
   > Gunakan keahlian atau waktu luangmu untuk membantu orang lain.
   
   Action: `Pelajari cara Jadi Mitra`

   Follow it with a short FAQ, not a large SEO block:
   - `Bagaimana memilih Mitra?`
   - `Apa yang terjadi jika Pesanan bermasalah?`
   - `Jasa apa yang tidak diperbolehkan?`

8. **Footer**  
   Close with task-based navigation and factual product information.

### Footer Detail

Organize the footer by task:

- **Jelajahi:** Kategori, Jasa lokal, Jasa digital, Buat Permintaan.
- **Untuk Mitra:** Jadi Mitra, Cara kerja, Panduan Mitra.
- **Keamanan dan bantuan:** Pusat bantuan, Aturan layanan, Laporkan masalah, Penyelesaian perselisihan.
- **Tentang Jasama:** Tentang, Ketentuan, Privasi.

Include the product name, a short factual description, copyright, and available contact channels. Do not add empty social links, app-store badges, awards, or partner logos.

## 3. Search and Service-Discovery Flow

### Entry Points

Discovery can begin from:

- Hero search.
- A category.
- `Jelajahi Jasa`.
- A service example.
- A Mitra profile.
- A saved or recent search for signed-in users.

### Search Suggestions

As the visitor types, suggestions may show:

- Matching categories.
- Specific Jasa.
- Mitra names.
- Common task phrases grounded in real search data when available.

Every suggestion must identify its type. Keyboard users can move through suggestions, hear the active option, submit the typed query, and dismiss the list.

### Results Structure

The results page begins with:

- Query and editable search field.
- Result summary in plain language.
- Clear distinction between `Jasa` and `Mitra`.
- Active filters with one `Hapus semua` action.
- Sort control with `Paling sesuai` as the default.

Recommended filters:

- `Jenis layanan`: Lokal or Digital.
- `Kategori`.
- `Lokasi` for local work; manually selected city or area because GPS tracking is out of scope.
- `Harga`.
- `Waktu pengerjaan` or availability when supported by actual listing data.
- `Rating`.
- `Status verifikasi`.

Do not show irrelevant location filters for digital-only results. Do not hide essential filtering behind horizontal chip rows that become difficult to scan.

### Mobile Discovery

- Search remains near the top of the results view.
- `Filter` and `Urutkan` are adjacent controls with active-filter counts.
- Filters open in a full-height sheet with labeled controls, `Terapkan`, and `Hapus semua`.
- Results use one readable column.
- Returning from a detail page restores the query, filters, result position, and focus.

### Browse-to-Request Bridge

When no suitable listing exists, preserve the visitor's work:

> **Belum menemukan yang cocok?**
>
> Gunakan pencarian ini sebagai awal Permintaan. Tambahkan detail, waktu, lokasi bila diperlukan, dan anggaran.

Action: `Buat Permintaan dari pencarian ini`

The query and applicable filters should prefill the Permintaan form. Never force the visitor to retype the task.

## 4. Category Model

Show two explicit category families. Each category uses a clear icon, name, and one short example—not a marketing paragraph.

### Lokal

- `Antar & Titip Beli`
- `Ambil Paket atau Dokumen`
- `Antre & Urusan Harian`
- `Bantuan Acara`

### Digital

- `Desain & Presentasi`
- `Video & Audio`
- `Belajar & Tutor`
- `Teknologi & Data`

Do not imply popularity until analytics exists. Initially use `Kategori utama`, `Pilihan untuk kebutuhan lokal`, and `Pilihan untuk pekerjaan digital`.

### Development and Staging Content

- Staging displays one persistent demo banner rather than labeling every card or photograph.
- Development and staging may use realistic synthetic prices, ratings, reviews, profiles, listings, and orders only on records carrying an `is_demo` data marker.
- Production rejects or excludes all records marked `is_demo`.
- Per-object `Data contoh` labels appear only when demo and real data are intentionally shown together.
- Synthetic data must never be presented as real customer evidence.
- Synthetic testimonials, public claims, aggregate statistics, partners, rankings, and performance evidence are not permitted as demo substitutes.

## 5. Service and Mitra Cards

### Jasa Card

Required information, in reading order:

1. Relevant thumbnail or portfolio preview.
2. Category and local/digital context.
3. Specific service title, limited to two lines.
4. Mitra name and truthful review state: `Profil Mitra diperiksa` in closed beta; do not use `Identitas terverifikasi`.
5. Location or `Dikerjakan online`.
6. Rating with review count, or `Belum ada ulasan`.
7. Price basis such as `Mulai dari` only when the record supports it; public production cards require real listing data.
8. Favorite action with an accessible name.

Optional information such as delivery time, availability, or completed orders appears only when measured and useful. Limit cards to two compact trust/status markers. The entire card may have one primary link while favorite remains a separate button with a safe interaction target.

**Sample title style**

- `Bantu ambil dan antar paket area Depok`
- `Desain presentasi rapi untuk kuliah atau kerja`
- `Edit video pendek untuk konten dan dokumentasi`

Avoid titles such as “Solusi terbaik untuk semua kebutuhan Anda.”

### Mitra Profile Card

Required information:

- Clear profile photo or approved placeholder.
- Mitra name.
- Primary specialty.
- Service area or `Melayani secara online`.
- Closed-beta profile-review state.
- Rating and review count, including a clear new-Mitra state.
- Two or three representative skills.
- `Lihat profil`.

Portfolio previews may appear when they materially help evaluation. Public production cards must not show invented response speed, completed-order counts, rankings, or “top provider” labels.

## 6. Trust, Verification, Ratings, and Safety

Trust signals must state what happened, not imply a blanket guarantee.

### Mitra Profile Review and Future Verification

- Closed beta collects no government ID or identity-match media and uses `Profil Mitra diperiksa` or another narrowly truthful equivalent.
- A visible explanation states that the review covers verified email/phone, profile completeness, portfolio where applicable, and manual onboarding eligibility.
- `Identitas terverifikasi` is prohibited in closed beta and remains reserved for a future approved and operational government-ID process.
- A profile without the reviewed status remains clear without publicly shaming a new Mitra.
- Additional checks, if later introduced, use distinct labels rather than one vague “verified” badge.

### Ratings and Reviews

- Show numeric rating and total review count together.
- Mark reviews that came from completed Pesanan.
- Use `Belum ada ulasan` for new Mitra instead of showing `0.0`.
- Show rating distribution and recent reviews on detail pages.
- Do not use ratings without counts or cherry-picked testimonials.

### Order and Safety Signals

The interface may explain these mechanisms once they are operational:

- Pesanan records scope, price, status, and submitted work or proof.
- In-platform messages and offers preserve agreed details.
- Users can report a Jasa, Mitra, message, or Pesanan.
- Basic dispute support has a visible entry point and stated process.
- Prohibited-service rules are visible before creating a listing or Permintaan.

Do not claim “100% aman,” “dijamin,” “pembayaran terlindungi,” or similar guarantees without the implemented policy, payment flow, and evidence to support them. Midtrans is later scope, so payment-security claims are excluded from the initial homepage.

## 7. Mobile-First Responsive Behavior

Design the small-screen flow first, then increase density where space permits.

- **Mobile:** one-column Jasa and Mitra results; two-column category grid; full-width search; stacked hero actions; no hover-dependent information.
- **Tablet:** two-column service results; balanced two-part hero when content remains readable; filter controls stay visible.
- **Desktop:** three or four service cards depending on content width; a compact hero with search and example tasks visible in the first viewport; filters may become a left rail when the result set benefits.

Additional rules:

- Body text remains comfortably readable without zoom.
- Essential touch targets are at least 44 by 44 CSS pixels.
- Long Indonesian labels wrap naturally and never truncate primary actions.
- Cards grow with content rather than forcing equal heights that hide information.
- Images declare stable aspect ratios to prevent layout shift.
- Focus order follows visual order.
- Sticky controls account for safe areas and do not cover content.
- Reduced-motion preferences remove non-essential transitions.

## 8. States and Feedback

### Loading

- Use layout-matching skeletons for cards and category rows.
- Search announces `Mencari jasa…` to assistive technology.
- Keep the previous results visible during filter updates when possible.
- Do not use full-page spinners for local updates.

### Empty

For a new account:

> **Belum ada Jasa tersimpan**
>
> Simpan Jasa atau Mitra yang ingin kamu pertimbangkan lagi.

Action: `Jelajahi Jasa`

For a category with no active listings, explain the absence and offer `Buat Permintaan`.

### No Results

> **Belum ada hasil untuk “{query}”**
>
> Coba istilah yang lebih umum, ubah filter, atau buat Permintaan agar Mitra dapat menawarkan bantuan.

Actions:

- `Hapus filter`
- `Buat Permintaan`

Do not frame the result as the user's mistake.

### Error

> **Hasil belum bisa dimuat**
>
> Periksa koneksi lalu coba lagi. Pencarian dan filtermu tetap tersimpan.

Actions:

- `Coba lagi`
- `Kembali ke Jelajahi Jasa`

Validation errors appear beside the affected field, describe how to fix it, and move focus to the first invalid field after submission.

### Success

Use persistent confirmation for important actions:

> **Permintaan berhasil dibuat**
>
> Kamu dapat memantau penawaran dan memperbarui detail dari dashboard.

Actions:

- `Lihat Permintaan`
- `Kembali ke beranda`

Favorites and filter changes may use quieter inline feedback. Never rely on color alone.

## 9. Interface Copy Principles

- Use direct, natural Indonesian.
- Prefer familiar verbs: `Cari`, `Lihat`, `Pilih`, `Simpan`, `Kirim`, `Batalkan`.
- Address the user as `kamu` where conversational guidance is useful; use neutral labels where repetition would feel childish.
- Explain unfamiliar marketplace terms the first time they appear.
- State consequences before destructive or binding actions.
- Avoid unexplained English, exaggerated claims, corporate filler, and youth slang.

### Recommended Copy Set

| Purpose | Copy |
|---|---|
| Homepage title | `Butuh bantuan untuk urusan lokal atau pekerjaan digital?` |
| Homepage support | `Temukan Mitra untuk kebutuhan sehari-hari, tugas kreatif, belajar, dan pekerjaan digital.` |
| Browse action | `Jelajahi Jasa` |
| Request action | `Buat Permintaan` |
| Provider action | `Jadi Mitra` |
| Search label | `Cari jasa` |
| Search placeholder | `Contoh: edit video, ambil paket, atau les matematika` |
| Trust heading | `Kenali Mitra sebelum memesan` |
| Custom-request heading | `Tidak menemukan Jasa yang pas?` |
| Safety link | `Pelajari keamanan Jasama` |
| New provider rating | `Belum ada ulasan` |
| Online service | `Dikerjakan online` |
| Local service area | `Melayani area {location}` |

## 10. Approved Visual Direction

The binding direction is **70% Koperasi Modern and 30% Papan Jasa Kota**, as defined in `DESIGN.md`. Koperasi Modern supplies structure, trust, information hierarchy, and durable marketplace patterns. Papan Jasa Kota supplies documentary imagery, Indonesian human warmth, practical service contexts, and community energy. This is one system, not two selectable themes.

### Structural Foundation — Koperasi Modern (70%)

**Visual concept**  
Reinterpret the clarity of cooperative records, work orders, member cards, and stamped receipts as a contemporary service marketplace. Structured fields make trust visible; human photography and direct copy keep the system from feeling bureaucratic.

**Emotional impression**  
Dependable, grounded, fair, organized, and quietly warm.

**Color direction**  
Deep cooperative green and near-black ink anchor the interface. Clean mineral white supports long reading. Saffron or turmeric yellow marks primary action and attention; a restrained brick red is reserved for warnings and urgent safety states. Colors are solid fields, not gradients.

**Typography character**  
A sturdy humanist sans for interface and reading, paired with a slightly narrower, confident sans for headings and category labels. Numerals must be highly legible for prices, ratings, and order status. Avoid fashionable display faces that age quickly.

**Shape language**  
Mostly rectangular surfaces, fine rules, modest corner rounding, clear field groupings, receipt-like dividers, and occasional clipped or notched details. Cards are used only for independent objects such as a Jasa or Mitra—not as wrappers for every section.

**Imagery direction**  
Documentary images of real Indonesian work contexts: hands carrying packages, a provider editing at a desk, printed documents being prepared, tutoring in a normal room, and finished digital artifacts. Framing feels observed and useful rather than aspirational stock photography.

**Icon style**  
Simple medium-weight outline icons with squared terminals and a filled active state. Icons clarify categories and actions; they never replace labels.

**Strengths**

- Makes trust and transaction structure tangible.
- Works for local and digital services without favoring either.
- Extends naturally into orders, dashboards, verification, and disputes.
- Broad enough for younger adults, families, professionals, and small businesses.
- Distinct from a generic SaaS marketplace while remaining easy to learn.

**Risks**

- Can feel institutional or government-like if the grid becomes dense.
- Receipt and stamp details can become decorative clichés.
- Requires warm imagery, plain language, and generous breathing room to preserve humanity.

**Approved role**  
This is the structural foundation. Its risk of feeling institutional is controlled through generous spacing, natural language, documentary imagery, and the Papan Jasa Kota contribution below.

### Human Warmth — Papan Jasa Kota (30%)

**Visual concept**  
Build Jasama like a well-curated neighborhood service board: storefront signs, parcel labels, posted work notices, and practical city information organized into a disciplined digital grid.

**Emotional impression**  
Approachable, active, local, resourceful, and community-minded.

**Color direction**  
Dark blue-green for authority, sunlit yellow for finding and highlighting, clay red for local warmth, and crisp neutral backgrounds. Colors appear in section bands, labels, and navigation landmarks rather than scattered accents.

**Typography character**  
A friendly grotesk for content with a compact, sturdy display sans for signs and headings. Category names feel immediately scannable. Hand-lettered styling is avoided so the system remains inclusive and professional.

**Shape language**  
Stacked bands, posted rectangles, straight edges, small label tabs, and strong alignment lines. Limited overlap may suggest a physical notice board, but content remains in one predictable reading order.

**Imagery direction**  
Close, contextual scenes of errands and digital work, plus useful portfolio crops. Photos may carry small factual captions such as service type or area; no fake testimonial quotation overlays.

**Icon style**  
Bold outlined pictograms inspired by public information signs, with consistent stroke and optical size.

**Strengths**

- Immediately communicates a marketplace of practical help.
- Has warm Indonesian urban character without relying on youth trends.
- Supports category browsing and diverse provider content well.
- Creates a recognizable public homepage with relatively little animation.

**Risks**

- Can become cluttered or informal if every block imitates a posted notice.
- Strong local cues may make digital services feel secondary.
- Needs strict density limits and an equally strong digital-work image library.

### Historical Research — Rute Bantuan (Not Implementation Authority)

This explored direction is retained as research for wayfinding and order-progress clarity. It is not an alternative visual system and must not override the approved 70/30 direction.

**Visual concept**  
Use the logic of public wayfinding, delivery routes, and service checkpoints. Search is the origin, a suitable Mitra is the destination, and the order process is a sequence of clear, visible steps.

**Emotional impression**  
Calm, efficient, legible, confident, and reassuring.

**Color direction**  
Deep civic navy, clear teal, signal orange, and bright neutral surfaces. Each color has a stable role: navigation, information, action, or warning. No purple-blue gradient and no glowing effects.

**Typography character**  
A highly legible signage-inspired sans with open forms, strong Indonesian diacritics support, and clear tabular numerals. Headings rely on scale and weight rather than decorative display typography.

**Shape language**  
Linear rails, route markers, indexed steps, firm rectangles, and modestly rounded controls. Lines express actual relationships such as search-to-order or local-versus-digital, never decorative motion paths.

**Imagery direction**  
Documentary task scenes framed like destinations or result stops. Digital work uses full-bleed artifact crops so it does not inherit a delivery-only visual language.

**Icon style**  
Wayfinding pictograms with consistent filled and outline variants. Status icons always include text.

**Strengths**

- Makes discovery and order progress exceptionally clear.
- Strong responsive logic: horizontal sequences become vertical routes on mobile.
- Supports locations, filters, states, and process education.
- Feels modern without relying on generic technology aesthetics.

**Risks**

- May resemble a delivery or transportation product too strongly.
- The route metaphor can become forced in dashboards or creative-service portfolios.
- Needs careful balance so digital work feels equal to local errands.

## 11. Scope and Explicit Anti-Goals

This shape covers:

- Public homepage.
- Initial search suggestions.
- Category browsing.
- Search results and filters.
- Jasa and Mitra discovery cards.
- The bridge from unsuccessful search to Buat Permintaan.
- Shared public loading, empty, error, success, and no-result patterns.

This shape does not cover:

- Authentication screens.
- Full Jasa detail or Mitra profile layouts.
- The Permintaan form beyond its discovery handoff.
- Messaging, offers, order management, or dashboards.
- Native applications, GPS tracking, wallet, video calls, AI features, or complex bidding.
- Final brand assets, exact design tokens, or component specifications.
- `DESIGN.md` or application implementation.

## 12. Approved Decisions and Launch Constraints

The homepage decisions are approved:

1. **Visual direction:** 70% Koperasi Modern and 30% Papan Jasa Kota.
2. **Action hierarchy:** `Jelajahi Jasa` is primary; `Buat Permintaan` is the prominent companion and fallback.
3. **Audience hierarchy:** Pemesan is primary; `Jadi Mitra` remains visible in navigation and later homepage content.
4. **Category scope:** eight homepage entry points—four Lokal and four Digital.
5. **Page scope:** the concise eight-part structure in Section 2.

Launch truth remains binding:

- The closed-beta `Profil Mitra diperiksa` status, future verification, dispute support, review provenance, recorded-order copy, reports, and status history may be presented as operational only after the corresponding mechanism works. Closed beta must not display `Identitas terverifikasi`.
- Development and staging may use realistic synthetic prices, ratings, reviews, profiles, listings, and orders under the persistent-banner, `is_demo`, and production-exclusion rules.
- In production and public-facing claims, fabricated testimonials, claims, statistics, ratings, reviews, prices, partners, rankings, and performance evidence are prohibited.
- Synthetic data must never be presented as real customer evidence.
- Public launch requires reviewed real content or explicitly approved production-safe assets; staging demo content never crosses into production.
