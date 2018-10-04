# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Create List of notification reasons
Reason.create({:name => "invitation", :description => "You accepted an invitation to contribute to the repository.", :order => 1})
Reason.create({:name => "mention", :description => "You were specifically @mentioned in the content.", :order => 2})
Reason.create({:name => "assign", :description => "You were assigned to the Issue.", :order => 3})
Reason.create({:name => "team_mention", :description => "You were on a team that was mentioned.", :order => 4})
Reason.create({:name => "manual", :description => "You subscribed to the thread (via an Issue or Pull Request).", :order => 5})
Reason.create({:name => "author", :description => "You created the thread.", :order => 6})
Reason.create({:name => "state_change", :description => "You changed the thread state.", :order => 7})
Reason.create({:name => "comment", :description => "You commented on the thread.", :order => 8})
Reason.create({:name => "subscribed", :description => "You're watching the repository.", :order => 9})
