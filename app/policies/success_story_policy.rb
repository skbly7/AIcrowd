class SuccessStoryPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    @record.published || (participant&.admin?)
  end

  def edit?
    false
  end

  def update?
    false
  end

  def new?
    false
  end

  def create?
    false
  end

  def destroy?
    false
  end

  class Scope
    attr_reader :participant, :scope

    def initialize(participant, scope)
      @participant = participant
      @scope       = scope
    end

    def resolve
      if participant&.admin?
        scope.all
      else
        scope.where(published: true)
      end
    end
  end
end
