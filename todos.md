# Todos

## Users should be able to edit/delete Topic Comment (inline)

>To continue this session, run codex resume 019f3cbe-034c-7433-a4bf-69fb8218f103

Add author-only edit and delete for topic comments, using Rails nested comment routes and Turbo-powered inline editing on the topic show page. No new JavaScript tooling or auth library changes.

### Key Changes

- Expand nested comment routes under topics to include edit, update, and destroy.
- Update CommentsController with:
  - edit: render an inline Turbo frame edit form for the comment.
  - update: allow only the comment author to change content; replace the comment frame on success and re-render the form on validation failure.
  - destroy: allow only the comment author to delete; remove the comment frame and update the displayed comment count.
  - Shared lookup scoped through current_condominium.topics.find(params[:topic_id]) to preserve condo isolation.
  - Shared ownership check using @comment.user == current_user; unauthorized attempts redirect back to the topic with an alert.

- Refactor app/views/topics/show.html.erb comment rendering into partials:
  - A comment display partial wrapped in turbo_frame_tag dom_id(comment).
  - An inline edit form partial for the same frame.
  - A small comment count target so deletion can update the count.

- Show Edit and Delete actions only for the current user’s own comments.
- Add/update locale keys in en, pt-BR, es, and ko for edit/delete/save/cancel/confirm and comment update/delete/unauthorized flash messages.
- Add minimal CSS for compact comment action buttons and inline edit form layout, reusing existing .btn, .btn-secondary, .btn-danger, and form styles.

### Public Interfaces

- Routes:
  - GET /topics/:topic_id/comments/:id/edit
  - PATCH/PUT /topics/:topic_id/comments/:id
  - DELETE /topics/:topic_id/comments/:id

- Params:
  - comment[content] remains the only permitted editable field.

- Authorization:
  - Only the original comment author can edit or delete.
  - Admins do not get special moderation rights in this change.

### Test Plan

- Add test/controllers/comments_controller_test.rb.
- Cover:
  - Authenticated author can update their comment and is redirected/replaced successfully.
  - Blank update fails and preserves validation behavior.
  - Authenticated author can delete their comment.
  - Non-author cannot update another user’s comment.
  - Non-author cannot delete another user’s comment.
  - User cannot access comments through a topic outside their condominium.

- Run bin/rails test.

## One-Vouch Service Listings

>To continue this session, run codex resume 019f399b-1597-79f2-b740-18bd475c4ddd

Users should be able to recommend/upvote service only once, just like the Topic upvote

Make service listing vouches persist per user, with the same toggle behavior as Topic upvotes: first click adds a vouch, second click removes it. Counts remain stored in service_listings.upvotes_count for sorting.

### Changes

- Add a service_listing_upvotes table with:
  - user_id
  - service_listing_id
  - timestamps
  - unique index on [user_id, service_listing_id]
  - foreign keys to users and service_listings

- Add a ServiceListingUpvote model:
  - belongs_to :user
  - belongs_to :service_listing, counter_cache: :upvotes_count
  - uniqueness validation scoped to service_listing_id

- Add associations:
  - User has_many :service_listing_upvotes, dependent: :destroy
  - ServiceListing has_many :service_listing_upvotes, dependent: :destroy

- Update ServiceListingsController#vouch:
  - find the listing through current_condominium.service_listings
  - if current user already vouched, destroy that record and show a removed message
  - otherwise create the record and show the existing success message

- Update the services dashboard:
  - mark the vouch button as active when service.service_listing_upvotes.exists?(user: current_user)
  - keep displaying service.upvotes_count

- Add locale keys for the removed/already toggled state, at minimum in en.yml; mirror the key in other existing locale files if needed to avoid missing
    translations.

### Tests

- Add model tests for ServiceListingUpvote:
  - valid with user and service listing
  - rejects duplicate vouches by the same user for the same service listing
  - updates service_listings.upvotes_count through counter cache

- Add controller tests for ServiceListingsController#vouch:
  - signed-in user can vouch once and count increases by 1
  - second vouch toggles off and count decreases by 1
  - vouching a listing from another condominium is not allowed through scoped lookup

- Run bin/rails test.
