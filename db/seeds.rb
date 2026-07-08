# Clear Database
puts "Clearing database..."
Session.destroy_all
Upvote.destroy_all
Comment.destroy_all
Topic.destroy_all
ServiceListing.destroy_all
User.destroy_all
Condominium.destroy_all

# Create Condominiums
puts "Creating condominiums..."
condo_a = Condominium.create!(
  name: "Grand Horizon Towers",
  address: "100 Skyline Blvd, Suite A",
  whatsapp_group_link: "https://chat.whatsapp.com/GC4T8BzRvJv2t7K9pQmXwA"
)

condo_b = Condominium.create!(
  name: "Green Valley Residences",
  address: "404 Meadow Lane"
)

# Create Users
puts "Creating users..."
# Condo A (Grand Horizon)
roberto = User.create!(
  condominium: condo_a,
  email_address: "roberto@horizon.com",
  password: "password",
  first_name: "Roberto",
  last_name: "Silva",
  role: :admin
)

julia = User.create!(
  condominium: condo_a,
  email_address: "julia@horizon.com",
  password: "password",
  first_name: "Julia",
  last_name: "Nunes",
  role: :resident
)

marcelo = User.create!(
  condominium: condo_a,
  email_address: "marcelo@horizon.com",
  password: "password",
  first_name: "Marcelo",
  last_name: "Dias",
  role: :resident
)

# Condo B (Green Valley)
ana = User.create!(
  condominium: condo_b,
  email_address: "ana@valley.com",
  password: "password",
  first_name: "Ana",
  last_name: "Santos",
  role: :admin
)

carlos = User.create!(
  condominium: condo_b,
  email_address: "carlos@valley.com",
  password: "password",
  first_name: "Carlos",
  last_name: "Gomes",
  role: :resident
)

# Create Topics for Condo A (Grand Horizon)
puts "Creating Grand Horizon topics..."
announcement_a = Topic.create!(
  condominium: condo_a,
  user: roberto,
  title: "Scheduled Water Maintenance — Thursday 2 PM",
  content: "Please note that the water supply will be temporarily shut off in both towers this Thursday from 2:00 PM to 4:30 PM for pressure valve replacements. We recommend storing some water for essential use during this period.",
  topic_type: :announcement
)

discussion_a = Topic.create!(
  condominium: condo_a,
  user: julia,
  title: "Strange clicking noise in Tower B main elevator?",
  content: "Has anyone else noticed a strange clicking sound in the main elevator of Tower B since yesterday morning? It feels slightly bumpier than usual when passing the 12th floor. Should we alert maintenance or is it already on their radar?",
  topic_type: :discussion
)

# Create Comments for Condo A Topic
Comment.create!(
  topic: discussion_a,
  user: marcelo,
  content: "Yes! I heard it this morning on my way down to the garage. It felt a bit bumpy around the 11th/12th floors for me too. Glad you posted this."
)

comment_reply = Comment.create!(
  topic: discussion_a,
  user: roberto,
  content: "Thanks for reporting this, Julia. I have logged a maintenance ticket with Otis Elevator Support. Their technician is scheduled to arrive tomorrow (Wednesday) at 9:00 AM to inspect the cab cables and rails."
)

# Create Upvotes for Condo A Topics
Upvote.create!(user: marcelo, upvotable: discussion_a)
Upvote.create!(user: roberto, upvotable: discussion_a)
Upvote.create!(user: julia, upvotable: announcement_a)

# Create Service Listings for Condo A
puts "Creating Grand Horizon service recommendations..."
ServiceListing.create!(
  condominium: condo_a,
  user: julia,
  title: "Mario's Pipeline Plumbing Specialists",
  category: "Plumbing",
  contact_info: "+55 (11) 98765-4321",
  description: "Mario did an incredible job fixing our bathroom pipe leak last week. He arrived within 45 minutes of calling, worked cleanly, explained everything clearly, and charged a very reasonable flat rate. Highly recommend him for emergency plumbing issues!",
  upvotes_count: 5
)

ServiceListing.create!(
  condominium: condo_a,
  user: marcelo,
  title: "Sparky Electric - Reliable & Licensed",
  category: "Electrical",
  contact_info: "sparky.electrics@outlook.com",
  description: "Used them to replace our breaker box and install new LED dimmers in our living room. Super professional, wore shoe covers, and finished under the estimated timeframe. Certified and fully insured.",
  upvotes_count: 2
)

# Create Topics & Listings for Condo B (Green Valley Residences)
puts "Creating Green Valley topics..."
announcement_b = Topic.create!(
  condominium: condo_b,
  user: ana,
  title: "Summer Pool Opening Rules and Guest Limits",
  content: "With summer starting, the pool is now officially open from 8:00 AM to 10:00 PM. Please remember that all guests must be accompanied by a resident, and a maximum of 4 guests are allowed per unit during weekends to prevent overcrowding.",
  topic_type: :announcement
)

discussion_b = Topic.create!(
  condominium: condo_b,
  user: carlos,
  title: "Lost key fob found near the gym treadmills",
  content: "Found a key ring with a blue car fob and a miniature copper key on the shelf near the treadmills around 6 PM today. I left them with the security guard at the gatehouse. Hope the owner finds them!",
  topic_type: :discussion
)

Comment.create!(
  topic: discussion_b,
  user: ana,
  content: "Thanks Carlos! I'll put a brief note about this in the lobby entrance board in case the owner doesn't check CondoHub."
)

Upvote.create!(user: carlos, upvotable: announcement_b)

ServiceListing.create!(
  condominium: condo_b,
  user: carlos,
  title: "Dona Maria's Home Cleaning",
  category: "Cleaning",
  contact_info: "+55 (11) 91111-2222",
  description: "Dona Maria has been cleaning our apartment bi-weekly for over a year. She is extremely thorough, reliable, and trustworthy. She brings all her own organic cleaning supplies.",
  upvotes_count: 8
)

puts "Database seeded successfully!"
