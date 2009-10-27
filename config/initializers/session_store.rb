# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_changer_session',
  :secret      => '0fa190b95a41a78a20a2dbd444ba2971ebf6308e0eb4c5f172af3b72cfe7b19b004ebb7c2521c27d733e50d233ed4ff75a9cc72db8773d862ce05e05267ea261'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
