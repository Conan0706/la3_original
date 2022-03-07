require "bundler/setup"
Bundler.require

ActiveRecord::Base.establish_connection

class User < ActiveRecord::Base
    has_secure_password
    has_many :chats;
    has_many :groups;
    has_many :tasks;
    has_many :members;
    has_many :groups, :through => :members;
end

class Group < ActiveRecord::Base
    has_many :chats;
    has_many :members;
    has_many :users, :through => :members
    belongs_to :user;
end

class Member < ActiveRecord::Base
    belongs_to :user;
    belongs_to :group;
end

class Chat < ActiveRecord::Base
    belongs_to :user;
    belongs_to :group;
end

class Task < ActiveRecord::Base
    belongs_to :user;
end