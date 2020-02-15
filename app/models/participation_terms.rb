class ParticipationTerms < ApplicationRecord
  include Markdownable

  before_create do
    self.version = if self.class.current_terms
                     self.class.current_terms.version + 1
                   else
                     1
                   end
  end

  def self.current_terms
    order('version desc').first
  end
end
