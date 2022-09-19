module Serializers
  class UserSerializer < Cerealizer::Base
    attributes :id, :first_name, :last_name, :created_at, :updated_at
    attribute :full_name, method: :full_name, tags: [ :full ]

    def full_name
      "#{object.first_name} #{object.last_name}"
    end
  end
end
