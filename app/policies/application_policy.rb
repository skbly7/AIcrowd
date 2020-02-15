class ApplicationPolicy
  attr_reader :participant, :record

  def initialize(participant, record)
    @participant = participant
    @record      = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    false
  end

  def update?
    false
  end

  def edit?
    false
  end

  def destroy?
    false
  end

  protected

  def cached_with_issues(method_name, out_issues_hash, &block)
    cache_key = "#{participant&.to_global_id}|#{record&.to_global_id}|#{method_name}"
    issues    = RequestStore.store[cache_key]
    if issues.nil?
      issues = {}
      # `yield` returns a conditions hash,
      #  which we reduce into an array of keys for which the value is truthy,
      #  of which the first is considered the most important
      issues[:list]                 = yield.each_with_object([]) { |(k, v), acc| acc << k if v; }
      issues[:sym]                  = issues[:list].first
      RequestStore.store[cache_key] = issues
    end
    out_issues_hash&.merge!(issues)
    !issues[:sym]
  end
end
