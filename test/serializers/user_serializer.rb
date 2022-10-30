module Serializers
  class UserSerializer < Cerealizer::Base
    attributes :id, :first_name, :last_name, :created_at, :updated_at
    attribute :full_name
    attribute :admin, method: :admin?, if: :admin?
    attribute :super_admin, method: :super_admin?, if: ->{ super_admin? }

    def full_name
      "#{object.first_name} #{object.last_name}"
    end

    def admin?
      object.permissions == "admin"
    end

    def super_admin?
      object.permissions == "super_admin"
    end
  end
end
