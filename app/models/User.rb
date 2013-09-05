class User
  include MongoMapper::Document


  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :validatable, :omniauthable

  key :email, String
  key :avatar_url, String
  key :home_town, String
  key :first_name, String
  key :last_name, String
  key :stats, Hash
  key :encrypted_password, String
  key :favourite_ids, Array
  key :local , String, :default=> 'none'
  key :figshare_id, String
  key :oauth_stuff, Hash

  timestamps!
  


  attr_accessor :first_name, :last_name, :home_town

  def self.find_for_fig_oauth(auth, signed_in_resource=nil)
    fig_id = auth[:uid]

    if user = self.where(:figshare_id => fig_id).first
      user.oauth_stuff =  oauth.to_hash
      user.save 
      user 
    else
      self.create(  :figshare_id => fig_id, 
                    :password => Devise.friendly_token[0,20], 
                    :oauth_stuff => auth.to_hash) 
    end
  end


  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    data = access_token.extra.raw_info
    if user = self.find_by_email(data.email)
      user
    else # Create a user with a stub password. 

      self.create(  :email => data.email, 
                    :password => Devise.friendly_token[0,20], 
                    :home_town=>data["hometown"]["name"],
                    :avatar_url => access_token.info["image"],
                    :first_name => access_token.info["first_name"],
                    :last_name => access_token.info["last_name"]) 
    end
  end

 
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"]
      end
    end
  end

 end
